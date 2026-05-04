variable "aws_region" {
  description = "AWS region for Localstack"
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "Localstack API endpoint"
  type        = string
  default     = "http://localhost:4566"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "observability-site"
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "container_port" {
  description = "Port exposed by container"
  type        = number
  default     = 80
}

variable "container_image" {
  description = "Docker image for ECS task"
  type        = string
  default     = "observability-site:latest"
}
