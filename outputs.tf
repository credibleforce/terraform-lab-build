/*###############################################
LAB 1
###############################################*/

output "lab1_kali_hosts" {
    value = module.lab1.kali_instances
}

output "lab1_centos_hosts" {
    value = module.lab1.centos_instances
}

output "lab1_ansible_hosts" {
    value = module.lab1.ansible_instances
}

output "lab1_win10_hosts" {
    value = module.lab1.win10_instances
}

output "lab1_win16_hosts" {
    value = module.lab1.win16_instances
}

output "lab1_hosts" {
    value = module.lab1.instances
}

output "custom_security_groups" {
    value = module.lab1.custom_security_groups
}

output "lab1_vpc_id" {
    value = module.lab1.vpc_id
}

output "lab1_elb_certs" {
    value = module.lab1_public_dns_mapping.elb_certs
}

output "lab1_elb" {
    value = module.lab1_public_dns_mapping.elb
}

output "lab1_instance_record" {
    value = module.lab1_public_dns_mapping.instance_record
}

output "lab1_elb_record" {
    value = module.lab1_public_dns_mapping.elb_record
}

/*###############################################
LAB 2
###############################################*/

# output "lab2_kali_hosts" {
#     value = module.lab2.kali_hosts
# }

# output "lab2_centos_hosts" {
#     value = module.lab2.centos_hosts
# }

# output "lab2_ansible_hosts" {
#     value = module.lab2.ansible_hosts
# }

# output "lab2_win10_hosts" {
#     value = module.lab2.win10_hosts
# }

# output "lab2_win16_hosts" {
#     value = module.lab2.win16_hosts
# }

# output lab2_internal_dns_records {
#     value = module.lab2_internal_dns.records
# }

# output lab2_public_dns_records {
#     value = module.lab2_public_dns.records
# }

# output lab2_public_certs {
#     value = module.lab2_public_dns.certs
# }