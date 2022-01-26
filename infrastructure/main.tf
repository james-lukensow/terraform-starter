

provider "aws" {
  region = var.primaryRegion
}

# Save state to S3. These parameters are populated by -backend-config
# args to terraform inint in the Make file
terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.65"
    }
  }
}

data "aws_region" "current" {}

locals {
  prefix              = "${var.projectPrefix}-${var.env}"
  location_index_name = "${var.projectPrefix}-${var.env}" // Same name as defined in shared/locationIndexCreate.sh and shared/locationIndexDestroy.sh
}


# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-2a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-2b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-2c"
}

resource "aws_ecr_repository" "terraform_api_repo" {
  name = "${local.prefix}-ecr-api-repo"
}

resource "aws_ecs_cluster" "terraform_cluster" {
  name = "${local.prefix}-cluster" # Naming the cluster
}

resource "aws_ecs_task_definition" "terraform_api_task" {
  family                   = "${local.prefix}-api-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${local.prefix}-api-task",
      "image": "${aws_ecr_repository.terraform_api_repo.repository_url}:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": ${var.ecsDefinitionMemory},
      "cpu": ${var.ecsDefinitionCpu},
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/${local.prefix}-api-cloudwatch",
            "awslogs-region": "us-east-2",
            "awslogs-stream-prefix": "ecs"
          }
       }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]             # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"                # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.ecsDefinitionMemory # Specifying the memory our container requires
  cpu                      = var.ecsDefinitionCpu    # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${local.prefix}-EcsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_alb" "application_load_balancer" {
  name               = "${local.prefix}-loadbalancer" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_lb_target_group" "target_group" {
  name        = "${local.prefix}-target"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our target group
  }
}

resource "aws_ecs_service" "terraform_api_service" {
  name            = "${local.prefix}-api-service"              # Naming our first service
  cluster         = aws_ecs_cluster.terraform_cluster.id           # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.terraform_api_task.arn # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = var.ecsServiceCount

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our target group
    container_name   = aws_ecs_task_definition.terraform_api_task.family
    container_port   = 3000 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
}

resource "aws_security_group" "service_security_group" {
  name = "${local.prefix}-service-security-group"
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  name = "${local.prefix}-load-balancer-security-group"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "terraform_api_cloudwatch" {
  name = "/${local.prefix}-api-cloudwatch"
}
