resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]
//module.b.module_complete

locals {
    hosts_override          = var.hosts_override
    override_hosts          = length(local.hosts_override) > 0 ? true : false
    host_count              = local.override_hosts ? length(local.hosts_override): var.host_count
    host_role               = var.host_role
    custom_security_groups  = var.custom_security_groups
}

resource "aws_route53_record" "internal_a" {
    depends_on = [null_resource.module_dependency]
    count                   = local.host_count
    zone_id                 = var.zone_id
    name                    = local.override_hosts ? local.hosts_override[count.index].name : format("%s%d", var.host_prefix, count.index + 1)
    type                    = "A"
    ttl                     = "300"
    records                 = ["${var.subnet_prefix}.${var.last_octet_base + count.index + 1}"]
}

resource "aws_instance" "host" {
    depends_on = [null_resource.module_dependency]
    count                   = local.host_count
    connection {
        type                = lookup(var.connection_settings, "type", "ssh")
        user                = lookup(var.connection_settings, "user", "root")
        password            = lookup(var.connection_settings, "password", null)
        host                = lookup(var.connection_settings, "host", self.public_ip)
        private_key         = lookup(var.connection_settings, "private_key", null)
        agent               = lookup(var.connection_settings, "agent", true)
        insecure            = lookup(var.connection_settings, "insecure", true)
        timeout             = lookup(var.connection_settings, "timeout", "5m")
        port                = lookup(var.connection_settings, "port", "22")
        https               = lookup(var.connection_settings, "https", false)
    }

    instance_type           = var.instance_type
    ami                     = var.image_id

    source_dest_check       =  true

    # attempt to locate the custom security group if available - else use provided security_group_id
    vpc_security_group_ids  = [local.override_hosts ? length([for sg in local.custom_security_groups: sg.id if sg.name == lookup(local.hosts_override[count.index],"custom_security_group",null)])>0 ? [for sg in local.custom_security_groups: sg.id if sg.name == lookup(local.hosts_override[count.index],"custom_security_group",null)][0] : var.security_group_id : var.security_group_id]

    key_name                = var.key_id
    subnet_id               = var.subnet_id
    private_ip              = "${var.subnet_prefix}.${var.last_octet_base + count.index + 1}"

    root_block_device {
        volume_type           = "gp2"
        volume_size           = var.volume_size
        delete_on_termination = "true"
    }

    tags = {
        Name                = local.override_hosts ? local.hosts_override[count.index].name : format("%s%d",var.host_prefix,count.index + 1)
        Role                = local.override_hosts ? join(",",concat([local.host_role],split(",",lookup(local.hosts_override[count.index],"role","")))): local.host_role
        Connection          = lookup(var.connection_settings, "type", "ssh")
    }

    user_data               = templatefile(var.provisioning_file, { "win_user" : "${var.win_user}", "win_password":"${var.win_password}", "short_name": "${local.override_hosts ? local.hosts_override[count.index].name : format("%s%d",var.host_prefix,count.index + 1)}", "full_name": "${local.override_hosts ? format("%s.%s",local.hosts_override[count.index].name, var.internal_domain) : format("%s%d.%s",var.host_prefix,count.index + 1,var.internal_domain)}"})

    provisioner "remote-exec" {
        inline = [
            "hostname",
        ]
    }
}

resource "null_resource" "module_is_complete" {
  depends_on = [aws_instance.host]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}