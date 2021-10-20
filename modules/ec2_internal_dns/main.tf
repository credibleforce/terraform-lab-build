resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]
//module.b.module_complete

resource "aws_route53_zone" "internal" {
    depends_on = [null_resource.module_dependency]
    name = var.internal_domain
    vpc {
        vpc_id = var.vpc_id
    }

    lifecycle {
        #ignore_changes = ["vpc"]
    }
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_route53_zone.internal]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}