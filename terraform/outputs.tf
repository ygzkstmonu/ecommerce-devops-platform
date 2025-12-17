# Terraform Outputs
# Display important information after deployment

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "EC2 instance public IP (Elastic IP)"
  value       = aws_eip.web.public_ip
}

output "instance_public_dns" {
  description = "EC2 instance public DNS"
  value       = aws_instance.web.public_dns
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i ssh-key.pem ubuntu@${aws_eip.web.public_ip}"
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${aws_eip.web.public_ip}:3000"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${aws_eip.web.public_ip}:5000"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_eip.web.public_ip}:9090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${aws_eip.web.public_ip}:3001"
}
