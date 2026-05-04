# Development environment configuration

aws_region           = "us-east-1"
localstack_endpoint  = "http://localhost:4566"
app_name             = "observability-site"
environment          = "dev"
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
container_port       = 80
container_image      = "observability-site:latest"
