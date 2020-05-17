resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]
resource "null_resource" "deployscript" {
  depends_on = [null_resource.module_dependency]
  connection {
      type = lookup(var.connection_settings, "type", "ssh")
      user = lookup(var.connection_settings, "user", "root")
      password = lookup(var.connection_settings, "password", null)
      host = lookup(var.connection_settings, "host", null)
      private_key = lookup(var.connection_settings, "private_key", null)
      agent = lookup(var.connection_settings, "agent", true)
      insecure = lookup(var.connection_settings, "insecure", true)
      timeout = lookup(var.connection_settings, "timeout", "5m")
      port = lookup(var.connection_settings, "port", "22")
      https = lookup(var.connection_settings, "https", false)
  }

  provisioner "remote-exec" {
    scripts = var.scripts
  }

  provisioner "remote-exec" {
    inline = var.inlines
  }
}

resource "null_resource" "module_is_complete" {
  depends_on = [null_resource.deployscript]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}