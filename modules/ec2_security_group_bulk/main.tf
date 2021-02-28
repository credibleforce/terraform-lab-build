resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]

resource "aws_security_group" "sg" {
    count = length(var.security_groups)
    depends_on = [null_resource.module_dependency]
    name        = var.security_groups[count.index].name
    vpc_id      = var.vpc_id

    ingress = [
      # append allow all in vpc
      for inbound_port in concat(var.security_groups[count.index].inbound_ports,[{
          source_port   = 0
          destination_port     = 0
          protocol    = "-1"
          cidr_blocks = [var.vpc_subnet]
          ipv6_cidr_blocks = null
          prefix_list_ids = null
          security_groups = null
          self = false
        }]): {
        from_port   = inbound_port.source_port
        to_port     = inbound_port.source_port
        protocol    = inbound_port.protocol
        cidr_blocks = lookup(inbound_port,"cidr_blocks",split(",",var.trusted_source)) 
        description = "allow inbound ${inbound_port.source_port}/${inbound_port.protocol} from ${var.trusted_source}"
        ipv6_cidr_blocks = null
        prefix_list_ids = null
        security_groups = null
        self = false
      }
    ]

    # outbound internet access
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = var.security_groups[count.index].name,
    }
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_security_group.sg]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}