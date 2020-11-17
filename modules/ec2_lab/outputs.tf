output "module_complete_simplistic" {
  value = null_resource.module_is_complete.id
}

# This is better, because it provides a "lineage".
output "module_complete" {
  value = "${var.module_dependency}${var.module_dependency == "" ? "" : "->"}${var.module_name}(${null_resource.module_is_complete.id})"
}

output "kali_instances" {
    value = local.kali_instances
}

output "centos_instances" {
    value = local.centos_instances
}

output "ansible_instances" {
    value = local.ansible_instances
}

output "win10_instances" {
    value = local.win10_instances
}

output "win16_instances" {
    value = local.win16_instances
}

output "instances" {
    value = local.instances
}

output "internal_zone_id" {
    value = module.ec2_internal_dns.zone_id
}

output "vpc_id" {
    value = module.ec2_network.vpc_id
}

output "vpc_subnet" {
    value = local.vpc_subnet
}

output subnet1_id {
    value = module.ec2_network.subnet1_id
}

output subnet2_id {
    value = module.ec2_network.subnet2_id
}

output "public_domain" {
    value = local.public_domain
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