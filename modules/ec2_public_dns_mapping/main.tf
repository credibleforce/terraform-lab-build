resource "null_resource" "module_dependency" {
  triggers = {
    dependency              = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]

data "aws_route53_zone" "public" {
    depends_on              = [null_resource.module_dependency]
    name                    = format("%s.",var.public_domain)
    private_zone            = false
}

locals {
  certs                     = [ for y in var.subdomains: y.name if y.cert==true ]
  elbs                      = [ for y in var.subdomains: { name=y.name, elb_type=y.elb_type, elb_health_check_target=y.elb_health_check_target, elb_source=y.elb_source, elb_source_port=y.elb_source_port, elb_destination_port=y.elb_destination_port, elb_protocol=y.elb_protocol, elb_destination_protocol=y.elb_destination_protocol, elb_source_protocol=y.elb_source_protocol } if y.elb==true]
  elb_certs                 = [ for y in aws_acm_certificate.cert: y ]
  # elb_sticky_ports          = flatten([ for y in aws_elb.elb: 
  #                                 [ for x in y.listener: { id=y.id, name=format("%s-%s",y.name,x.lb_port), lb_port=x.lb_port } ]
  #                             ])
  
  elb_instances             = flatten([ for y in var.subdomains:
                                  [ for x in var.instances: { elb_id=format("%s-%s",y.name,local.student_id), elb_destination_port=y.elb_destination_port, instance_id=x.instance_id } if y.elb==true && contains(split(",",y.targets),x.name) && x.student_id == local.student_id ]
                              ])
  elb_flat                  = []
  student_id                = var.student_id
  subdomains_elb            = [ for y in var.subdomains: y if y.elb==true ]
  subdomains_direct         = [ for y in var.subdomains: y if y.elb!=true ]
}

# create certificates
resource "aws_acm_certificate" "cert" {
    depends_on              = [null_resource.module_dependency]
    count                   = length(local.certs)
    domain_name             = format("%s.%s.%s",local.certs[count.index],var.student_id,var.public_domain)
    validation_method       = "DNS"
    tags = {
      Name = format("%s-%s",local.elbs[count.index].name, var.student_id)
    }
}

resource "aws_route53_record" "cert_validation" {
    depends_on              = [null_resource.module_dependency,aws_acm_certificate.cert]
    count                   = length(aws_acm_certificate.cert)
    name                    = aws_acm_certificate.cert[count.index].domain_validation_options.0.resource_record_name
    type                    = aws_acm_certificate.cert[count.index].domain_validation_options.0.resource_record_type
    zone_id                 = data.aws_route53_zone.public.id
    records                 = [aws_acm_certificate.cert[count.index].domain_validation_options.0.resource_record_value]
    ttl                     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  depends_on                = [null_resource.module_dependency,aws_route53_record.cert_validation]
  count                     = length(aws_acm_certificate.cert)
  certificate_arn           = aws_acm_certificate.cert[count.index].arn
  validation_record_fqdns   = [aws_route53_record.cert_validation[count.index].fqdn]
}

# create elb
resource "aws_security_group" "elb-sg" {
    count                   = length(local.elbs)
    depends_on              = [null_resource.module_dependency,aws_acm_certificate_validation.cert]
    name                    = format("%s-%s",local.elbs[count.index].name, var.student_id)
    vpc_id                  = var.vpc_id

    ingress {
                                from_port           = local.elbs[count.index].elb_source_port
                                to_port             = local.elbs[count.index].elb_destination_port
                                protocol            = local.elbs[count.index].elb_protocol
                                cidr_blocks         = split(",",local.elbs[count.index].elb_source)
                                description         = "allow inbound ${local.elbs[count.index].elb_source_port}/${local.elbs[count.index].elb_protocol} from ${local.elbs[count.index].elb_source}"
                                ipv6_cidr_blocks    = null
                                prefix_list_ids     = null
                                security_groups     = null
                                self                = false
    }

    # outbound internet access
    egress {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
    }

    tags = {
        Name                = format("%s-%s",local.elbs[count.index].name, var.student_id),
    }
}

# resource "aws_elb" "elb" {
#   count                     = length(local.elbs)
#   depends_on                = [null_resource.module_dependency,aws_acm_certificate.cert, aws_acm_certificate_validation.cert]
#   name                      = format("%s-%s",local.elbs[count.index].name, var.student_id)
#   subnets                   = [var.subnet1_id]
#   security_groups           = "${aws_security_group.elb-sg[format("%s.%s",local.elbs[count.index].name, var.student_id)].id}"

#   listener {
#     instance_port       = local.elbs[count.index].elb_destination_port
#     instance_protocol   = local.elbs[count.index].elb_destination_protocol
#     lb_port             = local.elbs[count.index].elb_source_port
#     lb_protocol         = local.elbs[count.index].elb_source_protocol
#     ssl_certificate_id  = "${aws_acm_certificate.cert[format("%s-%s",local.elbs[count.index].name, var.student_id)].arn}"
#   }

#   health_check {
#     healthy_threshold       =  2
#     unhealthy_threshold     =  2
#     timeout                 =  3
#     #Health check does not like redirects so we test a "final" url
#     target                  =  local.elbs[count.index].elb_health_check_target
#     interval                =  5
#   }
#   cross_zone_load_balancing =  true
#   idle_timeout              =  400
#   connection_draining       =  true
#   connection_draining_timeout  =  400

#   tags = {
#     Name = format("%s-%s",local.elbs[count.index].name, var.student_id)
#     DNSName = format("%s.%s",local.elbs[count.index].name, var.student_id)
#   }
# }

# resource "aws_elb_attachment" "elb" {
#   count                     = length(local.elb_instances)
#   depends_on                = [null_resource.module_dependency,aws_elb.elb]
#   elb                       = local.elb_instances[count.index].elb_id
#   instance                  = local.elb_instances[count.index].instance_id
# }

# resource "aws_lb_cookie_stickiness_policy" "elb" {
#   count                     = length(local.elb_sticky_ports)
#   depends_on                = [null_resource.module_dependency,aws_elb_attachment.elb]
#   name                      = local.elb_sticky_ports[count.index].name
#   load_balancer             = local.elb_sticky_ports[count.index].id
#   lb_port                   = local.elb_sticky_ports[count.index].lb_port
# }


resource "aws_lb" "load_balancer" {
  count                     = length(local.elbs)
  depends_on                = [null_resource.module_dependency,aws_acm_certificate.cert, aws_security_group.elb-sg]
  name                      = format("%s-%s",local.elbs[count.index].name, var.student_id)
  internal                  = false
  load_balancer_type        = local.elbs[count.index].elb_type
  subnets                   = [var.subnet1_id,var.subnet2_id]
  security_groups           = [ for y in aws_security_group.elb-sg: y.id if y.name == format("%s-%s",local.elbs[count.index].name, var.student_id) ]

  tags = {
    Name = format("%s-%s",local.elbs[count.index].name, var.student_id)
    DNSName = format("%s.%s",local.elbs[count.index].name, var.student_id)
  }
}

resource "aws_lb_target_group" "tg" {
  count                     = length(local.elbs)
  depends_on                = [null_resource.module_dependency,aws_lb.load_balancer]
  name                      = format("%s-%s",local.elbs[count.index].name, var.student_id)
  port                      = local.elbs[count.index].elb_destination_port
  protocol                  = upper(local.elbs[count.index].elb_destination_protocol)
  vpc_id                    = var.vpc_id
  target_type               = "instance"
  deregistration_delay      = 90
  health_check {
    interval                = 60
    port                    = local.elbs[count.index].elb_destination_port
    protocol                = upper(local.elbs[count.index].elb_destination_protocol)
    healthy_threshold       = 3
    unhealthy_threshold     = 3
  }
}

resource "aws_lb_listener" "listener" {
  count                     = length(local.elbs)
  depends_on                = [null_resource.module_dependency,aws_lb_target_group.tg]
  load_balancer_arn         = [ for y in aws_lb.load_balancer: y.arn if y.name == format("%s-%s",local.elbs[count.index].name,var.student_id)][0]
  port                      = local.elbs[count.index].elb_source_port
  protocol                  = upper(local.elbs[count.index].elb_source_protocol)
  certificate_arn           = [ for y in aws_acm_certificate.cert: y.arn if y.tags.Name == format("%s-%s",local.elbs[count.index].name, var.student_id)][0]
  
  default_action {
    target_group_arn        = [ for y in aws_lb_target_group.tg: y.arn if y.name == format("%s-%s",local.elbs[count.index].name, var.student_id)][0]
    type                    = "forward"
  }
}

resource "aws_lb_target_group_attachment" "tga1" {
  count                     = length(local.elb_instances)
  depends_on                = [null_resource.module_dependency,aws_lb_listener.listener]
  target_group_arn          = [ for y in aws_lb_target_group.tg: y.arn if y.name == format("%s-%s",local.elbs[count.index].name, var.student_id)][0]
  port                      = local.elb_instances[count.index].elb_destination_port
  target_id                 = local.elb_instances[count.index].instance_id
}

# create dns a records as required
resource "aws_route53_record" "instance_record" {
    depends_on              = [null_resource.module_dependency,aws_lb_target_group_attachment.tga1]
    count                   = length(local.subdomains_direct)
    zone_id                 = data.aws_route53_zone.public.zone_id
    name                    = format("%s.%s",local.subdomains_direct[count.index].name,var.student_id)
    type                    = "A"
    ttl                     = "300"
    records                 = [ for y in var.instances: y.public_ip if contains(split(",",local.subdomains_direct[count.index].targets),y.name)]
}

# create dns cname records for elb as required
resource "aws_route53_record" "elb_record" {
    depends_on              = [null_resource.module_dependency,aws_route53_record.instance_record]
    count                   = length(aws_lb.load_balancer)
    zone_id                 = data.aws_route53_zone.public.zone_id
    name                    = aws_lb.load_balancer[count.index].tags.DNSName
    type                    = "CNAME"
    ttl                     = "300"
    records                 = [aws_lb.load_balancer[count.index].dns_name]
}


resource "null_resource" "module_is_complete" {
  depends_on                = [null_resource.module_dependency,aws_route53_record.elb_record]

  provisioner "local-exec" {
    command                 = "echo Module is complete: ${var.module_name}___"
  }
}