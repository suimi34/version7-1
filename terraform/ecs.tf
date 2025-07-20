# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "rails" {
  name              = "/ecs/${var.project_name}/rails"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-rails-logs"
  }
}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/${var.project_name}/nginx"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-nginx-logs"
  }
}


# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECR read-only access for ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_ecr_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}



# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = var.nginx_image
      essential = true
      cpu       = var.nginx_cpu
      memory    = var.nginx_memory

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.nginx.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/health || exit 1"]
        interval    = 60
        timeout     = 10
        retries     = 10
        startPeriod = 60
      }

      dependsOn = [
        {
          containerName = "rails"
          condition     = "START"
        }
      ]
    },
    {
      name      = "rails"
      image     = var.rails_image
      essential = true
      cpu       = var.rails_cpu
      memory    = var.rails_memory

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "RAILS_ENV"
          value = "production"
        },
        {
          name  = "DB_HOST"
          value = var.db_host
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_user
        },
        {
          name  = "DB_PASS"
          value = var.db_pass
        },
        {
          name  = "SECRET_KEY_BASE"
          value = var.secret_key_base
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.rails.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/up || exit 1"]
        interval    = 60
        timeout     = 10
        retries     = 10
        startPeriod = 300
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-task-definition"
  }
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.main,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
  ]

  tags = {
    Name = "${var.project_name}-service"
  }
}
