output "module_complete_simplistic" {
  value = null_resource.module_is_complete.id
}

# This is better, because it provides a "lineage".
output "module_complete" {
  value = "${var.module_dependency}${var.module_dependency == "" ? "" : "->"}${var.module_name}(${null_resource.module_is_complete.id})"
}

output "kali_hosts" {
    value = [for h in module.kali_instances.hosts:   { instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
}

output "centos_hosts" {
    value = [for h in module.centos_instances.hosts:   { instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
}

output "ansible_hosts" {
    value = [for h in module.ansible_instances.hosts:   { instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
}

output "win10_hosts" {
    value = [for h in module.win10_instances.hosts:   { instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
}

output "win16_hosts" {
    value = [for h in module.win16_instances.hosts:   { instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
}

output "internal_zone_id" {
    value = module.ec2_internal_dns.zone_id
}

output "vpc_id" {
    value = module.ec2_network.vpc_id
}

output "student_id" {
    value = local.student_id
}

output "module_chain_output" {
    value = join(",",[module.ec2_network.module_complete,module.ec2_internal_dns.module_complete,module.linux_security_group.module_complete,module.win_security_group.module_complete,module.kali_instances.module_complete,module.win10_instances.module_complete,module.win16_instances.module_complete,module.ansible_instances.module_complete,module.centos_instances.module_complete,module.ansible_file_copy.module_complete,module.ansible_script_exec.module_complete])
}

output "custom_security_groups" {
    value = module.custom_security_groups.security_groups
}