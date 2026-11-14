output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability zones used by the subnets."
  value       = local.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs, in subnet index order."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs, in subnet index order."
  value       = aws_subnet.private[*].id
}

output "security_group_ids" {
  description = "Security group IDs, keyed by security group name."
  value       = { for key, security_group in aws_security_group.this : key => security_group.id }
}