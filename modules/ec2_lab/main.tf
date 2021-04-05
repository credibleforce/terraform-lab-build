resource "null_resource" "module_dependency" {
  triggers = {
    dependency = var.module_dependency
  }
}
//depends_on = [null_resource.module_dependency]
//module.b.module_complete

locals {
    vpc_name                = "${var.project_prefix}-s${var.student_id}-vpc"
    vpc_subnet              = "${var.vpc_subnet}"
    vpc_prefix              = "${split(".",local.vpc_subnet)[0]}.${split(".", local.vpc_subnet)[1]}"

    internal_domain         = var.internal_domain
    public_domain           = var.public_domain
    student_id              = var.student_id

    igw_name                = "${var.project_prefix}-s${var.student_id}-igw"

    subnet1_name            = "${var.project_prefix}-s${var.student_id}-subnet1"
    subnet1_prefix          = "${local.vpc_prefix}.1"
    subnet1_az              = "${var.subnet1_az}"

    subnet2_name            = "${var.project_prefix}-s${var.student_id}-subnet2"
    subnet2_prefix          = "${local.vpc_prefix}.2"
    subnet2_az              =  "${var.subnet2_az}"

    trusted_source          = var.trusted_source

    lb_security_group_name  = "${var.project_prefix}-s${var.student_id}-lb-sg"
    lb_security_inbound_ports =     [{
                                        source_port: 443
                                        destination_port: 443
                                        protocol: "tcp"
                                    }]

    linux_security_group_name = "${var.project_prefix}-s${var.student_id}-linux-sg"
    linux_security_inbound_ports =  [{
                                        source_port: 22
                                        destination_port: 22
                                        protocol: "tcp"
                                    }]

    win_security_group_name = "${var.project_prefix}-s${var.student_id}-win-sg"
    win_security_inbound_ports =    [{
                                        source_port: 3389
                                        destination_port: 3389
                                        protocol: "tcp"
                                    },{
                                        source_port: 5986
                                        destination_port: 5986
                                        protocol: "tcp"
                                    }]

    custom_security_groups  = var.custom_security_groups

    key_name                = "${var.project_prefix}-key"

    kali_ami                = var.kali_ami
    win08_ami               = var.win08_ami
    win10_ami               = var.win10_ami
    win12_ami               = var.win12_ami
    win16_ami               = var.win16_ami
    win19_ami               = var.win19_ami
    centos_ami              = var.centos_ami

    kali_user               = "kali"
    kali_hosts              = var.kali_hosts
    kali_instance_type      = "t2.micro"
    kali_prefix             = "kali"
    kali_role               = "kali"
    kali_volume_size        = "25"
    kali_last_octet_base    = 200
    kali_hosts_override     = var.kali_hosts_override

    win10_user              = "administrator"
    win10_hosts             = var.win10_hosts
    win10_instance_type     = "t2.medium"
    win10_prefix            = "win10"
    win10_role              = "win10"
    win10_volume_size       = "60"
    win10_last_octet_base   = 100
    win10_hosts_override    = var.win10_hosts_override

    win08_user              = "administrator"
    win08_hosts             = var.win08_hosts
    win08_instance_type     = "t2.medium"
    win08_prefix            = "win08"
    win08_role              = "win08"
    win08_volume_size       = "60"
    win08_last_octet_base   = 40
    win08_hosts_override    = var.win08_hosts_override

    win12_user              = "administrator"
    win12_hosts             = var.win12_hosts
    win12_instance_type     = "t2.medium"
    win12_prefix            = "win12"
    win12_role              = "win12"
    win12_volume_size       = "60"
    win12_last_octet_base   = 30
    win12_hosts_override    = var.win12_hosts_override

    win16_user              = "administrator"
    win16_hosts             = var.win16_hosts
    win16_instance_type     = "t2.medium"
    win16_prefix            = "win16"
    win16_role              = "win16"
    win16_volume_size       = "60"
    win16_last_octet_base   = 20
    win16_hosts_override    = var.win16_hosts_override

    win19_user              = "administrator"
    win19_hosts             = var.win19_hosts
    win19_instance_type     = "t2.medium"
    win19_prefix            = "win19"
    win19_role              = "win19"
    win19_volume_size       = "60"
    win19_last_octet_base   = 10
    win19_hosts_override    = var.win19_hosts_override

    ansible_deployment_user = var.ansible_deployment_user
    ansible_deployment_group = var.ansible_deployment_user
    ansible_user            = var.ansible_user
    ansible_group           = var.ansible_group
    ansible_hosts           = var.ansible_hosts
    ansible_instance_type   = "t2.medium"
    ansible_prefix          = "ansible"
    ansible_role            = "ansible"
    ansible_volume_size     = "60"
    ansible_last_octet_base = 50
    ansible_hosts_override  = var.ansible_hosts_override

    centos_user             = "centos"
    centos_hosts            = var.centos_hosts
    centos_instance_type    = "t2.medium"
    centos_prefix           = "centos"
    centos_role             = "centos"
    centos_volume_size      = "60"
    centos_last_octet_base  = 60
    centos_hosts_override   = var.centos_hosts_override

    win_user                = var.win_user
    win_password            = var.win_password

    ansible_template_vars = { 
        win_user                = local.win_user, 
        win_password            = local.win_password, 
        internal_domain         = local.internal_domain, 
        kali_hosts              = module.kali_instances.hosts, 
        win08_hosts             = module.win08_instances.hosts, 
        win10_hosts             = module.win10_instances.hosts, 
        win12_hosts             = module.win12_instances.hosts, 
        win16_hosts             = module.win16_instances.hosts, 
        win19_hosts             = module.win19_instances.hosts, 
        ansible_hosts           = module.ansible_instances.hosts, 
        centos_hosts            = module.centos_instances.hosts 
        ansible_deployment_user = local.ansible_deployment_user
        ansible_user            = local.ansible_user
        centos_user             = local.centos_user
        kali_user               = local.kali_user
    }

    ansible_inventory       = templatefile("${path.root}/templates/inventory.yml", local.ansible_template_vars)
    ansible_vars_base       = templatefile("${path.root}/templates/vars_base.yml", local.ansible_template_vars)
    
    ansible_private_dns     = length(module.ansible_instances.hosts)>0? module.ansible_instances.hosts[0].private_dns : null
    ansible_public_ip       = length(module.ansible_instances.hosts)>0? module.ansible_instances.hosts[0].public_ip : null

    aws_key_pair            = var.aws_key_pair

    kali_instances              = [for h in module.kali_instances.hosts:   { name= h.tags.Name, student_id=h.tags.StudentId, instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
    centos_instances            = [for h in module.centos_instances.hosts:   { name= h.tags.Name, student_id=h.tags.StudentId, instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
    ansible_instances           = [for h in module.ansible_instances.hosts:   { name= h.tags.Name, student_id=h.tags.StudentId, instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
    win10_instances             = [for h in module.win10_instances.hosts:   { name= h.tags.Name, student_id=h.tags.StudentId, instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
    win16_instances             = [for h in module.win16_instances.hosts:   { name= h.tags.Name, student_id=h.tags.StudentId, instance_id = h.id, arn = h.arn, public_ip = h.public_ip, public_dns = h.public_dns, private_ip = h.private_ip, private_dns = format("%s.%s",h.tags.Name,var.internal_domain), aws_private_dns = h.private_dns }]
    instances               = concat(local.kali_instances,local.centos_instances,local.ansible_instances,local.win10_instances,local.win16_instances)
}
  
module "ec2_network" {
    module_name             = "ec2_network"
    source                  = "../../modules/ec2_network"
    vpc_name                = local.vpc_name
    vpc_subnet              = local.vpc_subnet
    igw_name                = local.igw_name
    
    subnet1_name            = local.subnet1_name
    subnet1_prefix          = local.subnet1_prefix
    subnet1_az              = local.subnet1_az
    
    subnet2_name            = local.subnet2_name
    subnet2_prefix          = local.subnet2_prefix
    subnet2_az              = local.subnet2_az
}

module "ec2_internal_dns" {
    module_name             = "ec2_internal_dns"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_internal_dns"
    internal_domain         = local.internal_domain
    vpc_id                  = module.ec2_network.vpc_id
}

module "linux_security_group" {
    module_name             = "linux_security_group"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_security_group"
    vpc_id                  = module.ec2_network.vpc_id
    vpc_subnet              = local.vpc_subnet
    security_group_name     = local.linux_security_group_name
    inbound_ports           = local.linux_security_inbound_ports
    trusted_source          = local.trusted_source
}

module "win_security_group" {
    module_name             = "win_security_group"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_security_group"
    vpc_id                  = module.ec2_network.vpc_id
    vpc_subnet              = local.vpc_subnet
    security_group_name     = local.win_security_group_name
    inbound_ports           = local.win_security_inbound_ports
    trusted_source          = local.trusted_source
}

module "custom_security_groups" {
    module_name             = "custom_security_group"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_security_group_bulk"
    vpc_id                  = module.ec2_network.vpc_id
    vpc_subnet              = local.vpc_subnet
    security_groups         = local.custom_security_groups
    trusted_source          = local.trusted_source
}

module "kali_instances" {
    module_name             = "kali_instances"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_instance"
    host_count              = length(local.kali_hosts_override) > 0 ? length(local.kali_hosts_override) : local.kali_hosts
    hosts_override          = local.kali_hosts_override
    host_prefix             = local.kali_prefix
    host_role               = local.kali_role
    zone_id                 = module.ec2_internal_dns.zone_id
    internal_domain         = local.internal_domain
    connection_settings     =   { 
                                    user = local.kali_user, 
                                    private_key = file(replace(var.public_key_path,".pub","")) 
                                }
    instance_type           = local.kali_instance_type
    image_id                = local.kali_ami
    security_group_id       = module.linux_security_group.security_group_id
    key_id                  = local.aws_key_pair.id
    subnet_id               = module.ec2_network.subnet1_id
    subnet_prefix           = local.subnet1_prefix
    last_octet_base         = local.kali_last_octet_base
    volume_size             = local.kali_volume_size
    provisioning_file       = "${path.root}/templates/linux_provisioning.sh"
    custom_security_groups  = module.custom_security_groups.security_groups
    student_id              = var.student_id
}

module "win08_instances" {
    module_name             = "win08_instances"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_instance"
    host_count              = length(local.win08_hosts_override) > 0 ? length(local.win08_hosts_override) : local.win08_hosts
    hosts_override          = local.win08_hosts_override
    host_prefix             = local.win08_prefix
    host_role               = local.win08_role
    zone_id                 = module.ec2_internal_dns.zone_id
    internal_domain         = local.internal_domain
    connection_settings     =   { 
                                    type = "winrm", 
                                    user = local.win_user, 
                                    password = local.win_password, 
                                    agent = false, 
                                    https = true, 
                                    insecure = true, 
                                    timeout = "20m", 
                                    port = "5986",
                                    use_ntlm = true
                                }
    instance_type           = local.win08_instance_type
    image_id                = local.win08_ami
    security_group_id       = module.win_security_group.security_group_id
    key_id                  = local.aws_key_pair.id
    subnet_id               = module.ec2_network.subnet1_id
    subnet_prefix           = local.subnet1_prefix
    last_octet_base         = local.win08_last_octet_base
    volume_size             = local.win08_volume_size
    provisioning_file       = "${path.root}/templates/win_provisioning.ps1"
    win_user                = local.win_user
    win_password            = local.win_password
    custom_security_groups  = module.custom_security_groups.security_groups
    student_id              = var.student_id
    
}

module "win10_instances" {
    module_name             = "win10_instances"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_instance"
    host_count              = length(local.win10_hosts_override) > 0 ? length(local.win10_hosts_override) : local.win10_hosts
    hosts_override          = local.win10_hosts_override
    host_prefix             = local.win10_prefix
    host_role               = local.win10_role
    zone_id                 = module.ec2_internal_dns.zone_id
    internal_domain         = local.internal_domain
    connection_settings     =   { 
                                    type = "winrm", 
                                    user = local.win_user, 
                                    password = local.win_password, 
                                    agent = false, 
                                    https = true, 
                                    insecure = true, 
                                    timeout = "20m", 
                                    port = "5986",
                                    use_ntlm = true
                                }
    instance_type           = local.win10_instance_type
    image_id                = local.win10_ami
    security_group_id       = module.win_security_group.security_group_id
    key_id                  = local.aws_key_pair.id
    subnet_id               = module.ec2_network.subnet1_id
    subnet_prefix           = local.subnet1_prefix
    last_octet_base         = local.win10_last_octet_base
    volume_size             = local.win10_volume_size
    provisioning_file       = "${path.root}/templates/win_provisioning.ps1"
    win_user                = local.win_user
    win_password            = local.win_password
    custom_security_groups  = module.custom_security_groups.security_groups
    student_id              = var.student_id
}

module "win12_instances" {
    module_name             = "win12_instances"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_instance"
    host_count              = length(local.win12_hosts_override) > 0 ? length(local.win12_hosts_override) : local.win12_hosts
    hosts_override          = local.win12_hosts_override
    host_prefix             = local.win12_prefix
    host_role               = local.win12_role
    zone_id                 = module.ec2_internal_dns.zone_id
    internal_domain         = local.internal_domain
    connection_settings     =   { 
                                    type = "winrm", 
                                    user = local.win_user, 
                                    password = local.win_password, 
                                    agent = false, 
                                    https = true, 
                                    insecure = true, 
                                    timeout = "20m", 
                                    port = "5986",
                                    use_ntlm = true
                                }
    instance_type           = local.win12_instance_type
    image_id                = local.win12_ami
    security_group_id       = module.win_security_group.security_group_id
    key_id                  = local.aws_key_pair.id
    subnet_id               = module.ec2_network.subnet1_id
    subnet_prefix           = local.subnet1_prefix
    last_octet_base         = local.win12_last_octet_base
    volume_size             = local.win12_volume_size
    provisioning_file       = "${path.root}/templates/win_provisioning.ps1"
    win_user                = local.win_user
    win_password            = local.win_password
    custom_security_groups  = module.custom_security_groups.security_groups
    student_id              = var.student_id
    
}

module "win16_instances" {
    module_name             = "win16_instances"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_instance"
    host_count              = length(local.win16_hosts_override) > 0 ? length(local.win16_hosts_override) : local.win16_hosts
    hosts_override          = local.win16_hosts_override
    host_prefix             = local.win16_prefix
    host_role               = local.win16_role
    zone_id                 = module.ec2_internal_dns.zone_id
    internal_domain         = local.internal_domain
    connection_settings     =   { 
                                    type = "winrm", 
                                    user = local.win_user, 
                                    password = local.win_password, 
                                    agent = false, 
                                    https = true, 
                                    insecure = true, 
                                    timeout = "20m", 
                                    port = "5986",
                                    use_ntlm = true
                                }
    instance_type           = local.win16_instance_type
    image_id                = local.win16_ami
    security_group_id       = module.win_security_group.security_group_id
    key_id                  = local.aws_key_pair.id
    subnet_id               = module.ec2_network.subnet1_id
    subnet_prefix           = local.subnet1_prefix
    last_octet_base         = local.win16_last_octet_base
    volume_size             = local.win16_volume_size
    provisioning_file       = "${path.root}/templates/win_provisioning.ps1"
    win_user                = local.win_user
    win_password            = local.win_password
    custom_security_groups  = module.custom_security_groups.security_groups
    student_id              = var.student_id
    
}

module "win19_instances" {
    module_name             = "win19_instances"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_instance"
    host_count              = length(local.win19_hosts_override) > 0 ? length(local.win19_hosts_override) : local.win19_hosts
    hosts_override          = local.win19_hosts_override
    host_prefix             = local.win19_prefix
    host_role               = local.win19_role
    zone_id                 = module.ec2_internal_dns.zone_id
    internal_domain         = local.internal_domain
    connection_settings     =   { 
                                    type = "winrm", 
                                    user = local.win_user, 
                                    password = local.win_password, 
                                    agent = false, 
                                    https = true, 
                                    insecure = true, 
                                    timeout = "20m", 
                                    port = "5986",
                                    use_ntlm = true
                                }
    instance_type           = local.win19_instance_type
    image_id                = local.win19_ami
    security_group_id       = module.win_security_group.security_group_id
    key_id                  = local.aws_key_pair.id
    subnet_id               = module.ec2_network.subnet1_id
    subnet_prefix           = local.subnet1_prefix
    last_octet_base         = local.win19_last_octet_base
    volume_size             = local.win19_volume_size
    provisioning_file       = "${path.root}/templates/win_provisioning.ps1"
    win_user                = local.win_user
    win_password            = local.win_password
    custom_security_groups  = module.custom_security_groups.security_groups
    student_id              = var.student_id
    
}

module "ansible_instances" {
    module_name             = "ansible_instances"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_instance"
    host_count              = length(local.ansible_hosts_override) > 0 ? length(local.ansible_hosts_override) : local.ansible_hosts
    hosts_override          = local.ansible_hosts_override
    host_prefix             = local.ansible_prefix
    host_role               = local.ansible_role
    zone_id                 = module.ec2_internal_dns.zone_id
    internal_domain         = local.internal_domain
    connection_settings     =   { 
                                    user = local.ansible_user, 
                                    private_key = file(replace(var.public_key_path,".pub","")) 
                                }
    instance_type           = local.ansible_instance_type
    image_id                = local.centos_ami
    security_group_id       = module.linux_security_group.security_group_id
    key_id                  = local.aws_key_pair.id
    subnet_id               = module.ec2_network.subnet1_id
    subnet_prefix           = local.subnet1_prefix
    last_octet_base         = local.ansible_last_octet_base
    volume_size             = local.ansible_volume_size
    provisioning_file       = "${path.root}/templates/centos_provisioning.sh"
    custom_security_groups  = module.custom_security_groups.security_groups
    student_id              = var.student_id
}

module "centos_instances" {
    module_name             = "centos_instances"
    module_dependency       = module.ec2_network.module_complete
    source                  = "../../modules/ec2_instance"
    host_count              = length(local.centos_hosts_override) > 0 ? length(local.centos_hosts_override) : local.centos_hosts
    hosts_override          = local.centos_hosts_override
    host_prefix             = local.centos_prefix
    host_role               = local.centos_role
    zone_id                 = module.ec2_internal_dns.zone_id
    internal_domain         = local.internal_domain
    connection_settings     =   { 
                                    user = local.centos_user, 
                                    private_key = file(replace(var.public_key_path,".pub","")) 
                                }
    instance_type           = local.centos_instance_type
    image_id                = local.centos_ami
    security_group_id       = module.linux_security_group.security_group_id
    key_id                  = local.aws_key_pair.id
    subnet_id               = module.ec2_network.subnet1_id
    subnet_prefix           = local.subnet1_prefix
    last_octet_base         = local.centos_last_octet_base
    volume_size             = local.centos_volume_size
    provisioning_file       = "${path.root}/templates/centos_provisioning.sh"
    custom_security_groups  = module.custom_security_groups.security_groups
    student_id              = var.student_id
}

// ensure instances exist before ansible provisioning
resource "null_resource" "module_instance_provisioning_complete" {
  depends_on = [module.ec2_network,module.ec2_internal_dns,module.linux_security_group,module.win_security_group,module.kali_instances,module.win10_instances,module.win16_instances,module.ansible_instances,module.centos_instances]

  provisioner "local-exec" {
    command = "echo Module instance provisioning complete: ${var.module_name}___"
  }
}

module "ansible_file_copy" {
    module_name             = "ansible_file_copy"
    module_dependency       = null_resource.module_instance_provisioning_complete.id

    source                  = "../../modules/ec2_provision_file"
    connection_settings     =   { 
                                    host = local.ansible_public_ip,
                                    user = local.ansible_user, 
                                    private_key = file(replace(var.public_key_path,".pub","")) 
                                }
    files_copy              =   [
                                    { 
                                        source = "${path.root}/ansible/playbooks", 
                                        destination = "/home/${local.ansible_user}/deployment/ansible",
                                        type = "directory"
                                    },
                                    { 
                                        source = "${path.root}/ansible/ansible.cfg", 
                                        destination = "/home/${local.ansible_user}/deployment/ansible/ansible.cfg",
                                        type = "file"
                                    },
                                    { 
                                        source = replace(var.public_key_path,".pub",""),
                                        destination = "/home/${local.ansible_user}/.ssh/id_rsa",
                                        mode = 0600,
                                        type = "file"
                                    },
                                    { 
                                        source = var.public_key_path,
                                        destination = "/home/${local.ansible_user}/.ssh/id_rsa.pub",
                                        mode = 0644,
                                        type = "file"
                                    },
                                ]
    files_content           =   [
                                    { 
                                        content = local.ansible_inventory, 
                                        destination = "/home/${local.ansible_user}/deployment/ansible/inventory.yml",
                                        type = "file"
                                    },
                                    { 
                                        content = local.ansible_vars_base, 
                                        destination = "/home/${local.ansible_user}/deployment/ansible/vars_base.yml",
                                        type = "file"
                                    },
                                    { 
                                        content = templatefile("${path.root}/templates/ansible_base.sh", local.ansible_lab_vars),
                                        destination = "/home/${local.ansible_user}/ansible_base.sh",
                                        mode = 0755,
                                        type = "file"
                                    },
                                ]
}

module "ansible_script_exec" {
    module_name             = "ansible_script_exec"
    module_dependency       = module.ansible_file_copy.module_complete

    source                  = "../../modules/ec2_provision_script"
    connection_settings     =   { 
                                    host = local.ansible_public_ip,
                                    user = local.ansible_user, 
                                    private_key = file(replace(var.public_key_path,".pub","")) 
                                }
    inlines                 =   [
                                    "/home/${local.ansible_user}/ansible_base.sh",
                                    #"/home/${local.ansible_user}/ansible_deployment_user.sh"
                                ]
    scripts                 =   []
}

resource "null_resource" "module_is_complete" {
  depends_on = [module.ansible_file_copy,module.ansible_script_exec]

  provisioner "local-exec" {
    command = "echo Module is complete: ${var.module_name}___"
  }
}