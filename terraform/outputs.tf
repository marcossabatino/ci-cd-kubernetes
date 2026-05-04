output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = module.vpc.subnet_ids
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.vpc.security_group_id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.ecs_service_name
}
