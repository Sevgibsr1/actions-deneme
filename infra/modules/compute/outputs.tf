# Compute Modülü - Çıktılar

output "instance_ids" {
  description = "EC2 instance ID'leri"
  value       = aws_instance.web[*].id
}

output "instance_private_ips" {
  description = "EC2 instance private IP adresleri"
  value       = aws_instance.web[*].private_ip
}

output "instance_public_ips" {
  description = "EC2 instance public IP adresleri"
  value       = aws_instance.web[*].public_ip
}

output "elastic_ip" {
  description = "Elastic IP adresi (eğer oluşturulduysa)"
  value       = var.enable_elastic_ip ? aws_eip.web[0].public_ip : null
}

output "instance_arns" {
  description = "EC2 instance ARN'leri"
  value       = aws_instance.web[*].arn
}

