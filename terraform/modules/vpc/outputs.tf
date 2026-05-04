output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = aws_subnet.main[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.main.id
}

output "internet_gateway_id" {
  description = "Internet gateway ID"
  value       = aws_internet_gateway.main.id
}

output "route_table_id" {
  description = "Route table ID"
  value       = aws_route_table.main.id
}
