# Compute Modülü - EC2 Instance ve Docker Deployment
# Bu modül web uygulamasını çalıştıracak EC2 instance'ları oluşturur

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# En son Amazon Linux 2023 AMI'yi bul
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script - Docker ve Docker Compose kurulumu
locals {
  user_data = <<-EOF
#!/bin/bash
set -e

# System update
sudo yum update -y

# Docker kurulumu
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Docker Compose kurulumu
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Docker Compose dosyasını oluştur
sudo mkdir -p /opt/app
sudo tee /opt/app/docker-compose.yml > /dev/null <<'COMPOSE_EOF'
version: "3.9"

services:
  redis:
    image: redis:7-alpine
    command: ["redis-server", "--save", "60", "1", "--loglevel", "warning"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 2s
      retries: 10
    restart: unless-stopped
    networks:
      - app-network

  web:
    image: ${var.docker_image}
    environment:
      REDIS_HOST: redis
      REDIS_PORT: "6379"
      FLASK_RUN_HOST: 0.0.0.0
      FLASK_RUN_PORT: 5000
    ports:
      - "5000:5000"
    depends_on:
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
COMPOSE_EOF

# Systemd service oluştur
sudo tee /etc/systemd/system/docker-app.service > /dev/null <<'SERVICE_EOF'
[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/app
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Service'i başlat
sudo systemctl daemon-reload
sudo systemctl enable docker-app.service
sudo systemctl start docker-app.service

# Log'ları görmek için
sudo journalctl -u docker-app.service -f &
EOF
}

# EC2 Instance oluştur
resource "aws_instance" "web" {
  count = var.instance_count

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  user_data              = local.user_data

  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
    encrypted   = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-web-${count.index + 1}"
      Environment = var.environment
      Role        = "web-server"
    }
  )
}

# Elastic IP (opsiyonel - sadece ilk instance için)
resource "aws_eip" "web" {
  count    = var.enable_elastic_ip ? 1 : 0
  instance = aws_instance.web[0].id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-web-eip"
    }
  )
}

