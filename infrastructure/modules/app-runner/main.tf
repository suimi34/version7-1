# Data sources
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# SSM Parameters for sensitive data
resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.project_name}/${var.environment}/db_host"
  type  = "String"
  value = var.db_host

  tags = var.common_tags
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project_name}/${var.environment}/db_name"
  type  = "String"
  value = var.db_name

  tags = var.common_tags
}

resource "aws_ssm_parameter" "db_user" {
  name  = "/${var.project_name}/${var.environment}/db_user"
  type  = "String"
  value = var.db_user

  tags = var.common_tags
}

resource "aws_ssm_parameter" "db_pass" {
  name  = "/${var.project_name}/${var.environment}/db_pass"
  type  = "SecureString"
  value = var.db_pass

  tags = var.common_tags
}

resource "aws_ssm_parameter" "secret_key_base" {
  name  = "/${var.project_name}/${var.environment}/secret_key_base"
  type  = "SecureString"
  value = var.secret_key_base

  tags = var.common_tags
}

# ECR Repository Policy
resource "aws_ecr_repository_policy" "main" {
  repository = var.repository_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAppRunnerAccess"
        Effect = "Allow"
        Principal = {
          Service = "apprunner.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# IAM Role for App Runner Instance
resource "aws_iam_role" "app_runner_instance_role" {
  name = "${var.project_name}-app-runner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy for App Runner Instance - Parameter Store access
resource "aws_iam_role_policy" "app_runner_instance_policy" {
  name = "${var.project_name}-app-runner-instance-policy"
  role = aws_iam_role.app_runner_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/apprunner/${var.project_name}*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/*"
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ssm.${var.aws_region}.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alias/aws/ssm"
        ]
      }
    ]
  })
}

# Additional policy for broader Parameter Store access if needed
resource "aws_iam_role_policy" "app_runner_ssm_extended" {
  name = "${var.project_name}-app-runner-ssm-extended"
  role = aws_iam_role.app_runner_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:ListKeys",
          "kms:ListAliases"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for App Runner Access (to pull from ECR)
resource "aws_iam_role" "app_runner_access_role" {
  name = "${var.project_name}-app-runner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attach ECR Read policy to the access role
resource "aws_iam_role_policy_attachment" "app_runner_access_ecr" {
  role       = aws_iam_role.app_runner_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# Auto Scaling Configuration
resource "aws_apprunner_auto_scaling_configuration_version" "main" {
  auto_scaling_configuration_name = "${var.project_name}-auto-scaling"

  min_size = var.min_size
  max_size = var.max_size

  tags = var.common_tags
}

# App Runner Service
resource "aws_apprunner_service" "main" {
  service_name = "${var.project_name}-${var.environment}"

  source_configuration {
    auto_deployments_enabled = false

    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_access_role.arn
    }

    image_repository {
      image_configuration {
        port = var.app_runner_port
        runtime_environment_variables = merge(var.environment_variables, {
          DB_HOST         = aws_ssm_parameter.db_host.value
          DB_NAME         = aws_ssm_parameter.db_name.value
          DB_USER         = aws_ssm_parameter.db_user.value
          DB_PORT         = tostring(var.db_port)
          DB_PASS         = aws_ssm_parameter.db_pass.value
          SECRET_KEY_BASE = aws_ssm_parameter.secret_key_base.value
        })
      }
      image_identifier      = var.container_image
      image_repository_type = "ECR"
    }
  }

  instance_configuration {
    cpu               = var.app_runner_cpu
    memory            = var.app_runner_memory
    instance_role_arn = aws_iam_role.app_runner_instance_role.arn
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = var.health_check_path
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.main.arn

  tags = var.common_tags

  depends_on = [
    aws_iam_role.app_runner_access_role,
    aws_iam_role.app_runner_instance_role
  ]
}
