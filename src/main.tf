provider "aws" {
  region = "us-east-1" # Substitua pela região desejada
}

# Criar o API Gateway
resource "aws_api_gateway_rest_api" "pet_shop_api" {
  name = "PetShopAPI"
}

resource "aws_api_gateway_resource" "orders" {
  rest_api_id = aws_api_gateway_rest_api.pet_shop_api.id
  parent_id   = aws_api_gateway_rest_api.pet_shop_api.root_resource_id
  path_part   = "orders"
}

resource "aws_api_gateway_resource" "customers" {
  rest_api_id = aws_api_gateway_rest_api.pet_shop_api.id
  parent_id   = aws_api_gateway_rest_api.pet_shop_api.root_resource_id
  path_part   = "customers"
}

# Criar o ELB (Elastic Load Balancer)
resource "aws_lb" "pet_shop_lb" {
  name               = "pet-shop-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id
}

# Criar a função Lambda para Processar Pedidos
resource "aws_lambda_function" "process_orders" {
  function_name = "process_orders"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_code_hash = filebase64sha256("lambda_function.zip")
  filename         = "lambda_function.zip"
}

# Criar a função Lambda para Gerenciar Clientes
resource "aws_lambda_function" "manage_customers" {
  function_name = "manage_customers"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_code_hash = filebase64sha256("lambda_function.zip")
  filename         = "lambda_function.zip"
}

# Criar o ECS Cluster
resource "aws_ecs_cluster" "pet_services_cluster" {
  name = "pet_services_cluster"
}

# Criar o DynamoDB para Dados de Pets
resource "aws_dynamodb_table" "pets_data" {
  name           = "PetsData"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PetID"

  attribute {
    name = "PetID"
    type = "S"
  }
}

# Criar um Security Group para o Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.main.id

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

# VPC, Subnets, etc., que podem ser necessários (exemplo)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnets" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}
