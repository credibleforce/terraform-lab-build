resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]

data "aws_route53_zone" "public" {
    depends_on = [null_resource.module_dependency]
    name         = format("%s.",var.public_domain)
    private_zone = false
}

locals {
    cert_targets = [for y in var.subdomains: y.name if y.cert == true]
}

resource "aws_route53_record" "record" {
    depends_on = [null_resource.module_dependency]
    count = length(var.subdomains)
    zone_id = data.aws_route53_zone.public.zone_id
    name    = var.subdomains[count.index].name
    type    = upper(var.subdomains[count.index].type)
    ttl     = "300"
    records = [var.subdomains[count.index].target]
}

resource "aws_acm_certificate" "cert" {
    depends_on = [null_resource.module_dependency,aws_route53_record.record]
    count = length(local.cert_targets)
    domain_name       = format("%s.%s",local.cert_targets[count.index],var.public_domain)
    validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
    depends_on = [null_resource.module_dependency,aws_route53_record.record]
    count = length(local.cert_targets)
    name    = aws_acm_certificate.cert[count.index].domain_validation_options.0.resource_record_name
    type    = aws_acm_certificate.cert[count.index].domain_validation_options.0.resource_record_type
    zone_id = data.aws_route53_zone.public.id
    records = [aws_acm_certificate.cert[count.index].domain_validation_options.0.resource_record_value]
    ttl     = 60
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_route53_record.cert_validation]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}