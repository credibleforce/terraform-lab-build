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


resource "aws_route53_record" "record" {
    depends_on = [null_resource.module_dependency]
    count = length(var.subdomains)
    zone_id = data.aws_route53_zone.public.zone_id
    name    = var.subdomains[count.index].name
    type    = upper(var.subdomains[count.index].type)
    ttl     = "300"
    records = [var.subdomains[count.index].target]
}

resource "null_resource" "module_is_complete" {
  depends_on = [null_resource.module_dependency,aws_route53_record.record]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}