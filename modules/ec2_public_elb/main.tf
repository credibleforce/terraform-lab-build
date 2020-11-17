resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}

# ELB security group
resource "aws_security_group" "elb" {
    name        = "sg_splunk_elb"
    description = "splk elb"
    vpc_id      = aws_vpc.default.id
    
    # HTTPS access from anywhere
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = split(",",var.allowed_source_network)
    }

    # HTTPS access from anywhere
    ingress {
        from_port   = 443
        to_port     = 8088
        protocol    = "tcp"
        cidr_blocks = split(",",var.allowed_source_network)
    }

    # HTTPS access from anywhere
    ingress {
        from_port   = 443
        to_port     = 8000
        protocol    = "tcp"
        cidr_blocks = split(",",var.allowed_source_network)
    }

    # outbound internet access
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "splk-elb-sg",
    }
}

# SEARCH - load balancer
resource "aws_elb" "search" {
  count = length(local.splunk_search_head_ids) > 0 ? 1: 0
  name               = "splkshlb-search"
  subnets     = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]
  security_groups = [aws_security_group.elb.id]

  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = aws_acm_certificate_validation.search_cert[count.index].certificate_arn
  }

  health_check {
    healthy_threshold    =  2
    unhealthy_threshold  =  2
    timeout              =  3
    #Health check does not like redirects so we test a "final" url
    target               =  "HTTPS:443/en-US/account/login"
    interval             =  5
  }
  cross_zone_load_balancing    =  true
  idle_timeout                 =  400
  connection_draining          =  true
  connection_draining_timeout  =  400

  tags = {
    Name = "splk-search load balancer"
  }

  # excute after null resource is completed
  depends_on = [null_resource.deployment,aws_acm_certificate_validation.search_cert]
}


resource "null_resource" "module_is_complete" {
  depends_on = [null_resource.module_dependency]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}