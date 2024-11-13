
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Test = "crawler"
    }
  }
}

# Step 1: Create an ECR repository to store the Docker image
resource "aws_ecr_repository" "test_crawler_repository" {
  name = "crawler-chrome"
}

# Step 2: Create an ECS cluster to run the Fargate task
resource "aws_ecs_cluster" "test_crawler_cluster" {
  name = "my-cluster"
}

# Step 3: Define the task definition for the Fargate service
resource "aws_ecs_task_definition" "test_crawler_task" {
  family                   = "my-task"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 0.5 GB of memory

  container_definitions = jsonencode([
    {
        name      = "my-container"
        image     = "${aws_ecr_repository.test_crawler_repository.repository_url}:latest"  # Update with your image URL
        essential = true
    },
    {
        name      = "my-container-selenium"
        image     = "selenium/standalone-chrome:latest"  # Update with your image URL
        # sharedMemorySize  = "2g"
        essential = true
        portMappings = [
        {
            containerPort = 4444
            hostPort      = 4444
            protocol      = "tcp"
        }
        ]
    }
  ])
}

# Step 4: Define IAM roles for ECS execution and task roles
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Step 5: Create an AWS VPC for networking (if you don’t already have one)
resource "aws_vpc" "test_crawler_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "test_crawler_subnet" {
  vpc_id                  = aws_vpc.test_crawler_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-scan"
  }
}

# Step 6: Create a security group to allow traffic to the container (port 80 in this case)
resource "aws_security_group" "test_crawler_sg" {
  name        = "my-security-group"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.test_crawler_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# #service will be created by orchestrator

# # Step 7: Create an ECS service to run the task in Fargate
# resource "aws_ecs_service" "test_crawler_service" {
#   name            = "my-fargate-service"
#   cluster         = aws_ecs_cluster.test_crawler_cluster.id
#   task_definition = aws_ecs_task_definition.test_crawler_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
#   network_configuration {
#     subnets          = [aws_subnet.test_crawler_subnet.id]
#     security_groups = [aws_security_group.test_crawler_sg.id]
#     assign_public_ip = true
#   }
# }
