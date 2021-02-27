resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}

locals {
    cert_subdomains = [for sg in var.subdomains: sg if sg.cert == true]
}

data "aws_route53_zone" "public" {
    depends_on = [null_resource.module_dependency]
    name         = format("%s.",var.public_domain)
    private_zone = false
}

resource "aws_acm_certificate" "cert" {
    depends_on = [null_resource.module_dependency,aws_route53_zone.public]
    count = length(local.cert_domains)
    domain_name       = format("%s.%s",local.cert_domains[count.index],var.public_domain)
    validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
    depends_on = [null_resource.module_dependency,aws_acm_certificate.cert]
    count = length(aws_acm_certificate.cert)
    name    = aws_acm_certificate.cert[count.index].domain_validation_options.0.resource_record_name
    type    = aws_acm_certificate.cert[count.index].domain_validation_options.0.resource_record_type
    zone_id = data.aws_route53_zone.public.id
    records = [aws_acm_certificate.cert[count.index].domain_validation_options.0.resource_record_value]
    ttl     = 60
}

resource "null_resource" "module_is_complete" {
  depends_on = [null_resource.module_dependency,aws_route53_record.cert_validation]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}