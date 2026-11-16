output "instance_ids" {
  description = "EC2 instance IDs keyed by node name."
  value       = { for name, instance in aws_instance.this : name => instance.id }
}

output "private_ips" {
  description = "Private IP addresses keyed by node name."
  value       = { for name, instance in aws_instance.this : name => instance.private_ip }
}

output "public_ips" {
  description = "Public IP addresses keyed by node name (null if no public IP was assigned)."
  value       = { for name, instance in aws_instance.this : name => instance.public_ip }
}
