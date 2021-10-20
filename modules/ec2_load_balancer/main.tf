resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]


resource "null_resource" "module_is_complete" {
  depends_on = [null_resource.module_dependency]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}