resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]
//module.b.module_complete

resource "aws_route53_record" "internal" {
    depends_on = [null_resource.module_dependency]

    count = length(var.records)
    zone_id = var.zone_id
    name    = var.records[count.index].name
    type    = lookup(var.records[count.index],"type", "CNAME")
    ttl     = lookup(var.records[count.index],"ttl", "300")
    records = [var.records[count.index].target]
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_route53_record.internal]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}