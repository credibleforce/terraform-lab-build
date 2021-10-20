resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]

resource "aws_security_group" "sg" {
    depends_on = [null_resource.module_dependency]
    name        = var.security_group_name
    vpc_id      = var.vpc_id

    # All all from the VPC
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [var.vpc_subnet]
    }

    # outbound internet access
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = var.security_group_name,
    }
}

resource "aws_security_group_rule" "inbound_ports" {
    depends_on = [null_resource.module_dependency]
    count       = length(var.inbound_ports)
    type        = "ingress"
    from_port   = var.inbound_ports[count.index].source_port
    to_port     = var.inbound_ports[count.index].destination_port
    protocol    = var.inbound_ports[count.index].protocol
    cidr_blocks = split(",",var.trusted_source)
    security_group_id = aws_security_group.sg.id
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_security_group_rule.inbound_ports]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}