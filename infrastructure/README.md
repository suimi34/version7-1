# Infrastructure

This directory contains the unified Terraform infrastructure for deploying the application to both ECS Fargate and AWS App Runner.

## Directory Structure

```
infrastructure/
├── modules/                    # Reusable Terraform modules
│   ├── common/                # Shared variables and outputs
│   ├── networking/            # VPC, subnets, security groups (used by ECS)
│   ├── ecs/                   # ECS Fargate specific resources
│   └── app-runner/            # App Runner specific resources
└── environments/              # Environment-specific configurations
    ├── ecs/                   # ECS Fargate deployment
    └── app-runner/            # App Runner deployment
```

## Deployment Options

### Option 1: ECS Fargate with Load Balancer
- Full VPC with public/private subnets
- Application Load Balancer for external access
- ECS Fargate for container orchestration
- Nginx reverse proxy + Rails application
- More complex but provides more control

### Option 2: App Runner
- Serverless container deployment
- Direct HTTPS access
- Automatic scaling
- SSM Parameter Store for secrets
- Simpler setup, less infrastructure overhead

## Usage

### ECS Fargate Deployment

```bash
cd infrastructure/environments/ecs
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

### App Runner Deployment

```bash
cd infrastructure/environments/app-runner
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

## Common Configuration

Both deployment options share common variables through the `common` module:

- Database connection details
- Rails environment variables
- Container image configuration
- Project naming and tagging

## Migration from Old Structure

To migrate from the old `terraform/` and `infra/` directories:

1. Copy your `terraform.tfvars` values to the appropriate environment
2. Update container image URLs and repository names
3. Deploy using the new structure
4. Verify functionality
5. Remove old directories

## Benefits of New Structure

- **Code Reuse**: Common infrastructure patterns shared between deployments
- **Consistency**: Standardized variable names and resource tagging
- **Maintainability**: Modular design makes updates easier
- **Flexibility**: Easy to switch between deployment options or add new ones