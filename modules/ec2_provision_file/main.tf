resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}

resource "null_resource" "deployfile_content" {
    depends_on = [null_resource.module_dependency]

    count = length(var.files_content)
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
        use_ntlm = lookup(var.connection_settings, "use_ntlm", false)
    }

    # stage directories prior to copy
    provisioner remote-exec {
        inline = [
            "mkdir -p ${var.files_content[count.index].type == "directory" ? var.files_content[count.index].destination : dirname(var.files_content[count.index].destination) }"
        ]
    }

    provisioner "file" {
        content      = var.files_content[count.index].content
        destination = var.files_content[count.index].destination
    }

    provisioner remote-exec {
        inline = [for m in [var.files_content[count.index]]: format("chmod %s %s", m.mode, m.destination) if lookup(m, "mode", 0) != 0 ]
    }

    provisioner remote-exec {
        inline = [for m in [var.files_content[count.index]]: format("chmown %s:%s %s", m.owner, m.group, m.destination) if lookup(m, "owner", 0) != 0 && lookup(m, "group", 0) != 0 ]
    }
}

resource "null_resource" "deployfile_copy" {
    depends_on = [null_resource.module_dependency, null_resource.deployfile_content ]

    count = length(var.files_copy)
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
        use_ntlm = lookup(var.connection_settings, "use_ntlm", false)
    }

    # stage directories prior to copy
    provisioner remote-exec {
        inline = [
            "mkdir -p ${var.files_copy[count.index].type == "directory" ? var.files_copy[count.index].destination : dirname(var.files_copy[count.index].destination) }"
        ]
    }

    provisioner "file" {
        source      = var.files_copy[count.index].source
        destination = var.files_copy[count.index].destination
    }

    provisioner remote-exec {
        inline = [for m in [var.files_copy[count.index]]: format("chmod %s %s", m.mode, m.destination) if lookup(m, "mode", 0) != 0 ]
    }

    provisioner remote-exec {
        inline = [for m in [var.files_copy[count.index]]: format("chown %s:%s %s", m.owner, m.group, m.destination) if lookup(m, "owner", 0) != 0 && lookup(m, "group", 0) != 0 ]
    }
}

resource "null_resource" "module_is_complete" {
  depends_on = [null_resource.module_dependency,null_resource.deployfile_content,null_resource.deployfile_copy]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}