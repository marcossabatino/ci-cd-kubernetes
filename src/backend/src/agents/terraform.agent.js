import BaseAgent from './base.agent.js';

class TerraformAgent extends BaseAgent {
  constructor() {
    super({
      name: 'terraform',
      description: 'Helps with Terraform Infrastructure as Code planning, state management, and cloud resources',
      keywords: ['terraform', 'tf', 'infrastructure', 'iac', 'state', 'plan', 'apply', 'aws', 'provider', 'module', 'variable']
    });
  }

  async process(message, context = []) {
    const guidance = this.getTerraformGuidance(message);
    return this.formatResponse(guidance, { domain: 'terraform' });
  }

  getTerraformGuidance(message) {
    const lowerMessage = message.toLowerCase();

    if (lowerMessage.includes('state')) {
      return `
Terraform State Management:

The state file tracks your infrastructure:
- Stored in terraform.tfstate (default local backend)
- Maps Terraform code to real resources
- MUST be kept safe (production: use S3/Terraform Cloud)

Key commands:
\`\`\`bash
terraform state list              # List all resources
terraform state show resource.id  # Show specific resource
terraform state rm resource.id    # Remove from state
terraform refresh                 # Update state from cloud
\`\`\`

⚠️ Never manually edit terraform.tfstate!

Best practice: Store state in remote backends
\`\`\`hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
\`\`\`
      `;
    }

    if (lowerMessage.includes('plan') || lowerMessage.includes('apply')) {
      return `
Terraform Plan & Apply Workflow:

Step 1: Initialize
\`\`\`bash
terraform init
# Downloads provider plugins and initializes backend
\`\`\`

Step 2: Validate
\`\`\`bash
terraform validate
# Checks syntax and configuration
\`\`\`

Step 3: Format
\`\`\`bash
terraform fmt -recursive
# Formats HCL code
\`\`\`

Step 4: Plan
\`\`\`bash
terraform plan -out=tfplan
# Shows what WILL be created/modified/destroyed
# ALWAYS review this before apply!
\`\`\`

Step 5: Apply
\`\`\`bash
terraform apply tfplan
# Creates/modifies/destroys actual resources
\`\`\`

⚠️ Tips:
- Never skip reading plan output
- Use -lock to prevent concurrent changes
- Use workspaces for dev/prod separation
      `;
    }

    if (lowerMessage.includes('variable') || lowerMessage.includes('module')) {
      return `
Terraform Variables & Modules:

Variables (input):
\`\`\`hcl
variable "instance_count" {
  type        = number
  description = "Number of EC2 instances"
  default     = 1
  sensitive   = false
}
\`\`\`

Variables (output):
\`\`\`hcl
output "instance_ip" {
  value       = aws_instance.web.private_ip
  description = "Private IP of web instance"
}
\`\`\`

Modules (reusable components):
\`\`\`hcl
module "vpc" {
  source = "./modules/vpc"

  cidr_block = var.vpc_cidr
  name       = "main"
}

output "vpc_id" {
  value = module.vpc.id
}
\`\`\`

Pass variables via:
- CLI: terraform apply -var="instance_count=5"
- File: terraform apply -var-file="prod.tfvars"
- Env: export TF_VAR_instance_count=5
      `;
    }

    return `
Terraform Agent Ready!

I can help with:
- Infrastructure planning and design
- State management best practices
- Terraform workflow (init, plan, apply)
- Variable and module structure
- Cloud provider setup (AWS, GCP, Azure)

Try asking about: state, plan, apply, variable, module, provider
    `;
  }
}

export default TerraformAgent;
