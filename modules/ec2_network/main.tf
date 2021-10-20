resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}

resource "aws_vpc" "default" {
    depends_on           = [null_resource.module_dependency]
    cidr_block           = var.vpc_subnet
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = var.vpc_name
    }
}

resource "aws_internet_gateway" "default" {
    depends_on           = [null_resource.module_dependency]
    vpc_id = aws_vpc.default.id

    tags = {
        Name = var.igw_name
    }
}

resource "aws_route" "internet_access" {
    depends_on             = [null_resource.module_dependency]
    route_table_id         = aws_vpc.default.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "subnet1" {
    depends_on           = [null_resource.module_dependency]
    vpc_id                  = aws_vpc.default.id
    cidr_block              = "${var.subnet1_prefix}.0/24"
    availability_zone       = var.subnet1_az
    map_public_ip_on_launch = true
    
    tags = {
        Name = var.subnet1_name
    }
}

resource "aws_subnet" "subnet2" {
    depends_on              = [null_resource.module_dependency]
    vpc_id                  = aws_vpc.default.id
    cidr_block              = "${var.subnet2_prefix}.0/24"
    availability_zone       = var.subnet2_az
    map_public_ip_on_launch = true
    
    tags = {
        Name = var.subnet2_name
    }
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_subnet.subnet2]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}