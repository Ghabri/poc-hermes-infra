data "aws_vpcs" "vpcs" {
  tags = {
    app = "facturation-rest-app"
    environment = var.environment
  }
}

data "aws_subnet_ids" "public_subnet_ids" {
  vpc_id = sort(data.aws_vpcs.vpcs.ids)[0]
  tags = {
    app = "facturation-rest-app"
    environment = var.environment
    type = "public"
  }
}

data "aws_lb_target_group" "tg" {
  name = "https-facturation-rest-app-tg-${var.environment}"
}

resource "aws_ecs_cluster" "facturation-rest-app" {
  name = "facturation-rest-app-${var.environment}"

  capacity_providers = [
    "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1
  }

  tags = {
    app = "facturation-rest-app"
    environment = var.environment
  }
}

resource "aws_ecs_service" "facturation-rest-app" {
  name = "facturation-rest-app"
  cluster = aws_ecs_cluster.facturation-rest-app.id
  task_definition = aws_ecs_task_definition.aws_ecs_task_definition.arn
  desired_count = 2
  launch_type = "FARGATE"

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.tg.arn
    container_name = "facturation-rest-app"
    container_port = 8080
  }

  network_configuration {
    subnets = data.aws_subnet_ids.public_subnet_ids.ids
  }

  tags = {
    app = "facturation-rest-app"
    environment = var.environment
  }

}

resource "aws_ecs_task_definition" "aws_ecs_task_definition" {

  family = "facturation-rest-app-${var.environment}"
  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  container_definitions = <<DEFINITION
[
  {
    "name": "facturation-rest-app",
    "image": "poc-hermess/facturation-rest-app:latest",
    ,
    "portMappings": [
      {
        "hostPort": 8080,
        "containerPort": 8080
      }
    ],
    "essential": true
  }
]
DEFINITION
}