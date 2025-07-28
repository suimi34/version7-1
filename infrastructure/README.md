# Infrastructure

This directory contains the unified Terraform infrastructure for deploying the Rails application to both ECS Fargate and AWS App Runner environments.

## Directory Structure

```
infrastructure/
├── modules/                    # Reusable Terraform modules
│   ├── common/                # Shared variables and outputs across deployments
│   ├── networking/            # VPC, subnets, security groups (ECS only)
│   ├── ecs/                   # ECS Fargate specific resources
│   └── app-runner/            # App Runner specific resources
└── environments/              # Environment-specific configurations
    ├── ecs/                   # ECS Fargate deployment with ALB
    └── app-runner/            # App Runner serverless deployment
```

## Deployment Options

### Option 1: ECS Fargate with Load Balancer (Recommended for Production)

**Architecture:**

- Full VPC with public/private subnets across multiple AZs
- Application Load Balancer (ALB) for external access with SSL termination
- ECS Fargate cluster for container orchestration
- Multi-container setup: Nginx reverse proxy + Rails application
- Auto-scaling based on CPU/memory utilization

**Best for:**

- Production workloads requiring high availability
- Applications needing custom networking configurations
- Scenarios requiring detailed monitoring and logging
- Multi-service architectures

### Option 2: App Runner (Recommended for Simplicity)

**Architecture:**

- Fully managed serverless container platform
- Built-in HTTPS with automatic SSL certificates
- Automatic scaling from 0 to configured maximum
- Direct container deployment from ECR
- SSM Parameter Store integration for secrets

**Best for:**

- Development and staging environments
- Simple production workloads with predictable traffic
- Teams wanting minimal infrastructure management
- Cost-sensitive deployments (pay-per-use model)

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0 installed
- ECR repository with Rails application Docker image
- MySQL/PostgreSQL database accessible from AWS

## Usage

### ECS Fargate Deployment

```bash
cd infrastructure/environments/ecs
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values (see Configuration section below)
terraform init
terraform plan
terraform apply
```

**Required Configuration:**

- `repository_url`: ECR repository URL for Rails app
- `nginx_image`: ECR repository URL for Nginx image
- `db_host`, `db_name`, `db_user`, `db_pass`: Database connection details
- `secret_key_base`: Rails secret key base
- VPC and subnet CIDR blocks for networking

### App Runner Deployment

```bash
cd infrastructure/environments/app-runner
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values (see Configuration section below)
terraform init
terraform plan
terraform apply
```

**Required Configuration:**

- `repository_url`: ECR repository URL
- `db_host`, `db_name`, `db_user`, `db_pass`: Database connection details
- `secret_key_base`: Rails secret key base
- Auto-scaling and resource limits

## Configuration Details

### Common Variables (Both Deployments)

The following variables are shared through the `common` module:

| Variable          | Description                            | Default            | Required |
| ----------------- | -------------------------------------- | ------------------ | -------- |
| `aws_region`      | AWS region for deployment              | `ap-northeast-1`   | No       |
| `project_name`    | Project identifier for resource naming | `version7-1`       | No       |
| `environment`     | Environment name (dev/staging/prod)    | `production`       | No       |
| `db_host`         | Database hostname/endpoint             | -                  | **Yes**  |
| `db_port`         | Database port                          | `3306`             | No       |
| `db_name`         | Database name                          | `ze580_version7_1` | No       |
| `db_user`         | Database username                      | `ze580_version7_1` | No       |
| `db_pass`         | Database password                      | -                  | **Yes**  |
| `secret_key_base` | Rails secret key base                  | -                  | **Yes**  |
| `repository_url`  | ECR repository URL                     | -                  | **Yes**  |
| `image_tag`       | Docker image tag                       | `latest`           | No       |

### ECS-Specific Variables

| Variable               | Description                | Default                          | Required |
| ---------------------- | -------------------------- | -------------------------------- | -------- |
| `vpc_cidr`             | VPC CIDR block             | `10.0.0.0/16`                    | No       |
| `public_subnet_cidrs`  | Public subnet CIDR blocks  | `["10.0.1.0/24", "10.0.4.0/24"]` | No       |
| `private_subnet_cidrs` | Private subnet CIDR blocks | `["10.0.2.0/24", "10.0.3.0/24"]` | No       |
| `nginx_image`          | Nginx container image URL  | -                                | **Yes**  |
| `task_cpu`             | ECS task CPU units         | `512`                            | No       |
| `task_memory`          | ECS task memory (MB)       | `1024`                           | No       |
| `desired_count`        | Number of running tasks    | `1`                              | No       |

### App Runner-Specific Variables

| Variable            | Description                | Default | Required |
| ------------------- | -------------------------- | ------- | -------- |
| `app_runner_cpu`    | CPU units for App Runner   | `256`   | No       |
| `app_runner_memory` | Memory (MB) for App Runner | `512`   | No       |
| `app_runner_port`   | Application port           | `3000`  | No       |
| `min_size`          | Minimum instances          | `1`     | No       |
| `max_size`          | Maximum instances          | `1`     | No       |
| `health_check_path` | Health check endpoint      | `/up`   | No       |

## Troubleshooting

### Common Issues

**1. ECR Repository Access**

```bash
# Ensure Docker is authenticated with ECR
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-northeast-1.amazonaws.com
```

**2. Database Connectivity**

- Verify database security groups allow inbound connections
- Ensure database endpoint is reachable from AWS resources
- Check database credentials and permissions

**3. SSL Certificate Issues (ECS)**

- ALB automatically provisions SSL certificates via ACM
- Ensure domain validation is completed

**4. App Runner Build Failures**

- Check ECR image exists and is accessible
- Verify container exposes the correct port (3000)
- Review App Runner service logs in CloudWatch

### Validation Commands

```bash
# Check Terraform plan before applying
terraform plan -detailed-exitcode

# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt -recursive

# Check resource dependencies
terraform graph | dot -Tpng > graph.png
```

## Migration from Old Structure

To migrate from the old `terraform/` and `infra/` directories:

1. **Backup existing state**: `terraform state pull > terraform.tfstate.backup`
2. **Copy configuration**: Transfer `terraform.tfvars` values to appropriate environment
3. **Update image URLs**: Ensure ECR repository URLs are correct
4. **Plan migration**: Review `terraform plan` output carefully
5. **Apply incrementally**: Consider using `-target` for critical resources
6. **Verify functionality**: Test application endpoints and database connectivity
7. **Clean up**: Remove old directories after successful migration

## Cost Optimization

### ECS Fargate

- Use Spot instances for non-critical workloads
- Right-size CPU and memory allocations
- Implement proper auto-scaling policies
- Consider Reserved Capacity for predictable workloads

### App Runner

- Monitor concurrent request patterns
- Adjust auto-scaling parameters based on usage
- Use health check grace periods effectively
- Consider cold start implications

## Security Best Practices

- Store sensitive variables in AWS Systems Manager Parameter Store
- Use IAM roles with least-privilege access
- Enable VPC Flow Logs for network monitoring (ECS)
- Regularly update container images with security patches
- Implement proper logging and monitoring with CloudWatch

## Benefits of This Architecture

- **Code Reuse**: Shared modules reduce duplication and ensure consistency
- **Environment Parity**: Identical configurations across dev/staging/prod
- **Flexibility**: Easy switching between deployment options
- **Maintainability**: Modular design simplifies updates and troubleshooting
- **Scalability**: Both options support horizontal scaling
- **Security**: Built-in AWS security best practices
