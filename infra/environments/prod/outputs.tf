# Production Ortamı - Çıktılar

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet ID'leri"
  value       = module.vpc.public_subnet_ids
}

output "instance_ids" {
  description = "EC2 instance ID'leri"
  value       = module.compute.instance_ids
}

output "instance_public_ips" {
  description = "EC2 instance public IP adresleri"
  value       = module.compute.instance_public_ips
}

output "instance_private_ips" {
  description = "EC2 instance private IP adresleri"
  value       = module.compute.instance_private_ips
}

output "web_urls" {
  description = "Web uygulaması URL'leri"
  value       = [for ip in module.compute.instance_public_ips : "http://${ip}:5000"]
}

output "elastic_ip" {
  description = "Elastic IP adresi (eğer oluşturulduysa)"
  value       = module.compute.elastic_ip
}

