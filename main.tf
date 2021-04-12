
locals {
    project_prefix              = "lab"
    lab_base_tld                = var.lab_base_tld
    lab_base_name               = var.lab_base_name
    internal_domain             = "${var.lab_base_name}.${var.lab_base_tld}"
    win_netbios_domain          = upper(local.lab_base_name)
    win_ca_common_name          = "${upper(local.lab_base_name)}-PKI"
    public_domain               = var.public_domain
    win08_ami                   = var.win08_ami
    win12_ami                   = data.aws_ami.win12.image_id
    win10_ami                   = var.win10_ami
    win16_ami                   = data.aws_ami.win16.image_id
    win19_ami                   = data.aws_ami.win19.image_id
    centos_ami                  = data.aws_ami.centos.image_id
    kali_ami                    = data.aws_ami.kali.image_id
    trusted_source              = trimspace(data.local_file.trusted-source.content)
    win_admin_user              = var.win_admin_user
    win_admin_password          = var.win_admin_password
    splunk_password             = var.splunk_password
    splunkbase_token            = var.splunkbase_token
    ansible_awx_password        = var.ansible_awx_password
    ansible_awx_pg_password     = var.ansible_awx_pg_password
    ansible_awx_secret_key      = var.ansible_awx_secret_key
    vault_passwd                = var.vault_passwd

    
    win08_hosts                 = 0
    win08_hosts_override        =   [
                                        #{ name="win08-srv1", role="member_server" },
                                    ]

    win10_hosts                 = 0
    win10_hosts_override        =   [
                                        { name="win10-dsk1", role="member_server" },
                                    ]

    win12_hosts                 = 0
    win12_hosts_override        =   [
                                        #{ name="win12-srv1", role="member_server" },
                                    ]

    win16_hosts                 = 0
    win16_hosts_override        =   [
                                        #{ name="win16-dc1", role="domain_controller,certificate_authority,splunk_universal_forwarder" },
                                        #{ name="win16-wef1", role="wef_server,splunk_universal_forwarder" },
                                        #{ name="win16-svr1", role="member_server" },
                                    ]

    win19_hosts                 = 0
    win19_hosts_override        =   [
                                        { name="win19-dc1", role="domain_controller,certificate_authority,splunk_universal_forwarder" },
                                        { name="win19-wef1", role="wef_server,splunk_universal_forwarder" },
                                        { name="win19-svr1", role="member_server" },
                                    ]
    
    kali_hosts                  = 0
    kali_hosts_override         =   [
                                        #{ name="kali-pen1", role="member_server" },
                                    ]

    centos_hosts                = 0
    centos_hosts_override       =   [
                                        {name="splk-sh1", role="splunk_standalone", custom_security_group="splunk_security_group"},
                                        #{name="splk-sh1", role="splunk_search_head", custom_security_group="splunk_security_group"},
                                        #{name="splk-sh2", role="splunk_search_head", custom_security_group="splunk_security_group"},
                                        #{name="splk-sh3", role="splunk_search_head,splunk_search_head_captain", custom_security_group="splunk_security_group"},
                                        #{name="splk-lm1", role="splunk_license_master", custom_security_group="splunk_security_group"},
                                        #{name="splk-dp1", role="splunk_deployment_server,splunk_license_master", custom_security_group="splunk_security_group"},
                                        #{name="splk-cm1", role="splunk_cluster_master", custom_security_group="splunk_security_group"},
                                        #{name="splk-sdp1", role="splunk_deployer", custom_security_group="splunk_security_group"},
                                        #{name="splk-idx1", role="splunk_indexer", custom_security_group="splunk_security_group"},
                                        #{name="splk-idx2", role="splunk_indexer", custom_security_group="splunk_security_group"},
                                        #{name="splk-hf1", role="splunk_heavy_forwarder", custom_security_group="splunk_security_group"},
                                        #{name="splk-uf1", role="splunk_universal_forwarder", custom_security_group="splunk_security_group"},
                                        #{name="lin-syslog1", role="syslog_collector", custom_security_group="syslog_security_group"},
                                    ]
    splunk_user                 = var.splunk_user
    ansible_user                = var.ansible_user
    kali_user                   = var.kali_user
    centos_user                 = var.centos_user
    win08_user                  = var.win08_user
    win10_user                  = var.win10_user
    win12_user                  = var.win12_user
    win16_user                  = var.win16_user
    win19_user                  = var.win19_user

    ansible_group               = "centos"
    ansible_deployment_user     = "deployer"
    ansible_deployment_group    = "deployer"
    ansible_hosts               = 0
    ansible_hosts_override      =   [
                                        {name="ansible-srv1", custom_security_group="ansible_security_group"},
                                    ]
    ansible_private_dns         = length(module.lab1.ansible_instances)>0? module.lab1.ansible_instances[0].private_dns : null
    ansible_public_ip           = length(module.lab1.ansible_instances)>0? module.lab1.ansible_instances[0].public_ip : null
    
    custom_security_groups      =   [
                                        { name="splunk_security_group", inbound_ports=  [ 
                                                                                            { source_port=22,destination_port=22,protocol="tcp" },
                                                                                            { source_port=443,destination_port=443,protocol="tcp" },
                                                                                            { source_port=8000,destination_port=8000,protocol="tcp" },
                                                                                            { source_port=8000,destination_port=8088,protocol="tcp" },
                                                                                            { source_port=8089,destination_port=8089,protocol="tcp" },
                                                                                            { source_port=9997,destination_port=9997,protocol="tcp" },
                                                                                            { source_port=9998,destination_port=9998,protocol="tcp" },
                                                                                        ]
                                        },
                                        { name="ansible_security_group", inbound_ports=  [ 
                                                                                            { source_port=22,destination_port=22,protocol="tcp" },
                                                                                            #{ source_port=443,destination_port=443,protocol="tcp" }
                                                                                        ]
                                        },
                                        { name="syslog_security_group", inbound_ports=  [ 
                                                                                            { source_port=22,destination_port=22,protocol="tcp" },
                                                                                            { source_port=514,destination_port=514,protocol="tcp" },
                                                                                            { source_port=514,destination_port=514,protocol="udp" }
                                                                                        ]
                                        },
                                    ]

    public_dns_mapping          =   [
                                        # enable load balancing for 443 => 8000
                                        {   
                                            name="search", 
                                            targets="splk-sh1", 
                                            cert=true, 
                                            elb=true,
                                            elb_type="application",
                                            elb_port_sticky_sessions=true, 
                                            elb_health_check_target="TCP:8000", 
                                            elb_source=local.trusted_source, 
                                            elb_source_port=443, 
                                            elb_destination_port=8000, 
                                            elb_protocol="tcp", 
                                            elb_source_protocol="https", 
                                            elb_destination_protocol="https" 
                                        },
                                        # enable load balancing for 443 => 8089
                                        {   
                                            name="deploy", 
                                            targets="splk-sh1", 
                                            cert=true, 
                                            elb=true,
                                            elb_type="application",
                                            elb_port_sticky_sessions=true, 
                                            elb_health_check_target="TCP:8089", 
                                            elb_source=local.trusted_source, 
                                            elb_source_port=443, 
                                            elb_destination_port=8089, 
                                            elb_protocol="tcp", 
                                            elb_source_protocol="https", 
                                            elb_destination_protocol="https" 
                                        },
                                        # enable load balacing for 443 => 8088
                                        {   name="forward", 
                                            targets="splk-sh1", 
                                            cert=true, 
                                            elb=true,
                                            elb_type="application",
                                            elb_port_sticky_sessions=true, 
                                            elb_health_check_target="TCP:8088", 
                                            elb_source=local.trusted_source, 
                                            elb_source_port=443, 
                                            elb_destination_port=8088, 
                                            elb_protocol="tcp", 
                                            elb_source_protocol="https", 
                                            elb_destination_protocol="https" 
                                        },
                                        # disable load balancing for indexer
                                        {   name="index", 
                                            targets="splk-sh1", 
                                            cert=false, 
                                            elb=false,
                                            elb_type="application",
                                            elb_port_sticky_sessions=true, 
                                            elb_health_check_target="TCP:9997", 
                                            elb_source=local.trusted_source, 
                                            elb_source_port=9997, 
                                            elb_destination_port=9997, 
                                            elb_protocol="tcp", 
                                            elb_source_protocol="https", 
                                            elb_destination_protocol="https" 
                                        },
                                        # enable load balacing for 443 => 80
                                        {   name="manage", 
                                            targets="ansible-srv1", 
                                            cert=true, 
                                            elb=true,
                                            elb_type="application",
                                            elb_port_sticky_sessions=true, 
                                            elb_health_check_target="TCP:443", 
                                            elb_source=local.trusted_source, 
                                            elb_source_port=443, 
                                            elb_destination_port=443, 
                                            elb_protocol="tcp", 
                                            elb_source_protocol="https", 
                                            elb_destination_protocol="https" 
                                        },
                                        # public dns mapping for ansible
                                        {   name="admin", 
                                            targets="ansible-srv1", 
                                            cert=false, 
                                            elb=false,
                                            elb_type="application",
                                            elb_port_sticky_sessions=null, 
                                            elb_health_check_target=null, 
                                            elb_source=local.trusted_source, 
                                            elb_source_port=null, 
                                            elb_destination_port=null, 
                                            elb_protocol=null, 
                                            elb_source_protocol=null, 
                                            elb_destination_protocol=null 
                                        },
                                        # public dns mapping for desktop
                                        {   name="student", 
                                            targets="win10-dsk1", 
                                            cert=false, 
                                            elb=false,
                                            elb_type="application",
                                            elb_port_sticky_sessions=null, 
                                            elb_health_check_target=null, 
                                            elb_source=local.trusted_source, 
                                            elb_source_port=null, 
                                            elb_destination_port=null, 
                                            elb_protocol=null, 
                                            elb_source_protocol=null, 
                                            elb_destination_protocol=null 
                                        },
                                    ]

    key_name                    = "${local.project_prefix}-key"
    public_key_path             = "~/.ssh/id_rsa.pub"

    ansible_lab_vars = {
        internal_domain         = local.internal_domain
        lab_base_tld            = local.lab_base_tld
        lab_base_name           = local.lab_base_name
        win_netbios_domain      = local.win_netbios_domain
        win_admin_user          = local.win_admin_user
        win_admin_password      = local.win_admin_password
        win_ca_common_name      = local.win_ca_common_name
        splunk_password         = local.splunk_password
        splunkbase_token        = local.splunkbase_token
        ansible_awx_password    = local.ansible_awx_password
        ansible_awx_pg_password = local.ansible_awx_pg_password
        ansible_awx_secret_key  = local.ansible_awx_secret_key
        splunk_user             = local.splunk_user
        ansible_user            = local.ansible_user
        centos_user             = local.centos_user
        kali_user               = local.kali_user
        win08_user              = local.win08_user
        win10_user              = local.win10_user
        win12_user              = local.win12_user
        win16_user              = local.win16_user
        win19_user              = local.win19_user
    }

    ansible_lab_settings       = templatefile("${path.root}/templates/lab_settings.yml", local.ansible_lab_vars)
}

module "environment" {
    module_name                 = "environment"
    source                      = "./environments/dev"
    key_name                    = local.key_name
    public_key_path             = local.public_key_path
}

resource "null_resource" "vault-passwd" {
    provisioner "local-exec" {
        command                 = "echo -n '${local.vault_passwd}' > '${path.root}/settings/vault_passwd.txt'"
    }
}

resource "null_resource" "trusted-local-source" {
    provisioner "local-exec" {
        command                 = "echo -n $(dig +short @resolver1.opendns.com myip.opendns.com)/32 > '${path.root}/settings/local-trusted-source.txt'"
    }
}

data "local_file" "trusted-source" {
    filename                    = "${path.root}/settings/local-trusted-source.txt"
    depends_on                  = [null_resource.trusted-local-source]
}

resource "local_file" "lab_settings" {
    content                     = local.ansible_lab_settings
    filename                    = "${path.root}/settings/lab_settings.tmp"
}

/*###############################################
LAB 1
###############################################*/

module "lab1" {
    module_name                 = "lab1"
    module_dependency           = module.environment.module_complete
    source                      = "./modules/ec2_lab"
    trusted_source              = local.trusted_source
    kali_ami                    = local.kali_ami
    win08_ami                   = local.win08_ami
    win10_ami                   = local.win10_ami
    win12_ami                   = local.win12_ami
    win16_ami                   = local.win16_ami
    win19_ami                   = local.win19_ami
    centos_ami                  = local.centos_ami
    aws_region                  = var.aws_region
    project_prefix              = local.project_prefix
    public_domain               = local.public_domain
    student_id                  = "lab1"
    win_admin_user              = local.ansible_lab_vars.win_admin_user
    win_admin_password          = local.ansible_lab_vars.win_admin_password
    internal_domain             = local.ansible_lab_vars.internal_domain
    win_netbios_domain          = local.ansible_lab_vars.win_netbios_domain
    win_ca_common_name          = local.ansible_lab_vars.win_ca_common_name
    splunk_password             = local.ansible_lab_vars.splunk_password
    splunkbase_token            = local.ansible_lab_vars.splunkbase_token
    ansible_awx_password        = local.ansible_lab_vars.ansible_awx_password
    ansible_awx_pg_password     = local.ansible_lab_vars.ansible_awx_pg_password
    ansible_awx_secret_key      = local.ansible_lab_vars.ansible_awx_secret_key
    lab_base_tld                = local.lab_base_tld
    lab_base_name               = local.lab_base_name
    win08_hosts                 = local.win08_hosts
    win08_hosts_override        = local.win08_hosts_override
    win10_hosts                 = local.win10_hosts
    win10_hosts_override        = local.win10_hosts_override
    win12_hosts                 = local.win12_hosts
    win12_hosts_override        = local.win12_hosts_override
    win16_hosts                 = local.win16_hosts
    win16_hosts_override        = local.win16_hosts_override
    win19_hosts                 = local.win19_hosts
    win19_hosts_override        = local.win19_hosts_override
    kali_hosts                  = local.kali_hosts
    kali_hosts_override         = local.kali_hosts_override
    centos_hosts                = local.centos_hosts
    centos_hosts_override       = local.centos_hosts_override
    ansible_hosts               = local.ansible_hosts
    ansible_hosts_override      = local.ansible_hosts_override
    aws_key_pair                = module.environment.key_pair
    public_key_path             = local.public_key_path
    ansible_group               = local.ansible_group
    custom_security_groups      = local.custom_security_groups
    splunk_user                 = local.splunk_user
    ansible_user                = local.ansible_user
    kali_user                   = local.kali_user
    centos_user                 = local.centos_user
    win08_user                  = local.win08_user
    win10_user                  = local.win10_user
    win12_user                  = local.win12_user
    win16_user                  = local.win16_user
    win19_user                  = local.win19_user
    vault_passwd                = local.vault_passwd
}

# // add additional dns records internally
# module "lab1_internal_dns" {
#     module_name                 = "lab1_internal_dns"
#     module_dependency       = module.lab1.module_complete

#     source                      = "./modules/ec2_internal_dns_record"
#     zone_id                     = module.lab1.internal_zone_id
#     records                     =   [
#                                         {
#                                             name = "deployer"
#                                             type = "CNAME"
#                                             target = module.lab1.ansible_instances[0].private_dns
#                                         }
#                                     ]
# }

// add public dns records (in the format NAME.STUDENT_ID.PUBLIC_DOMAIN)
module "lab1_public_dns_mapping" {
    module_name                 =   "lab1_public_dns_mapping"
    module_dependency           =   module.lab1.module_complete

    source                      =   "./modules/ec2_public_dns_mapping"
    public_domain               =   module.lab1.public_domain
    vpc_id                      =   module.lab1.vpc_id
    vpc_subnet                  =   module.lab1.vpc_subnet
    subnet1_id                  =   module.lab1.subnet1_id
    subnet2_id                  =   module.lab1.subnet2_id
    student_id                  =   module.lab1.student_id
    instances                   =   module.lab1.instances
    subdomains                  =   local.public_dns_mapping
}

// copy over extended ansible setup
module "lab1_files" {
    module_name                 = "lab1_files"
    module_dependency           = module.lab1.module_complete

    source                  = "./modules/ec2_provision_file"
    connection_settings     =   { 
                                    host = module.lab1.ansible_instances[0].public_ip,
                                    user = local.ansible_user, 
                                    private_key = file(replace(local.public_key_path,".pub","")) 
                                }
    files_copy              =   [
                                    {
                                        source = "/tmp/splunk.lic",
                                        destination = "/tmp/splunk.lic"
                                        type = "file"
                                    },
                                ]
    files_content           =   [
                                    { 
                                        content = templatefile("${path.root}/templates/ansible_domain_deployment.sh", local.ansible_lab_vars),
                                        destination = "/home/${local.ansible_user}/ansible_domain_deployment.sh",
                                        mode = 0755
                                        type = "file"
                                    },
                                    { 
                                        content = templatefile("${path.root}/templates/ansible_splunk_deployment.sh",  local.ansible_lab_vars),
                                        destination = "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
                                        mode = 0755
                                        type = "file"
                                    },
                                ]
}

# // execute extended ansible setup
module "lab1_script_exec" {
    module_name             = "lab1_script_exec"
    module_dependency       = module.lab1_files.module_complete

    source                  = "./modules/ec2_provision_script"
    connection_settings     =   { 
                                    host = module.lab1.ansible_instances[0].public_ip,
                                    user = local.ansible_user, 
                                    private_key = file(replace(local.public_key_path,".pub","")) 
                                }
    inlines                 =   [
                                    #"/home/${local.ansible_user}/ansible_domain_deployment.sh",
                                    #"/home/${local.ansible_user}/ansible_splunk_deployment.sh",
                                ]
    scripts                 =   []
}

/*###############################################
LAB 2
###############################################*/

# module "lab2" {
#     module_name                 = "lab2"
#     module_dependency           = module.environment.module_complete
#     source                      = "./modules/ec2_lab"
#     trusted_source              = local.trusted_source
#     kali_ami                    = local.kali_ami
#     win08_ami                   = local.win08_ami
#     win10_ami                   = local.win10_ami
#     win12_ami                   = local.win12_ami
#     win16_ami                   = local.win16_ami
#     win19_ami                   = local.win19_ami
#     centos_ami                  = local.centos_ami
#     aws_region                  = var.aws_region
#     project_prefix              = local.project_prefix
#     public_domain               = local.public_domain
#     internal_domain             = local.internal_domain
#     student_id                  = "lab2"
#     win_admin_user              = local.ansible_lab_vars.win_admin_user
#     win_admin_password          = local.ansible_lab_vars.win_admin_password
#     interal_domain              = local.ansible_lab_vars.interal_domain
#     win_netbios_domain          = local.ansible_lab_vars.win_netbios_domain
#     win_ca_common_name          = local.ansible_lab_vars.win_ca_common_name
#     splunk_password             = local.ansible_lab_vars.splunk_password
#     splunkbase_token            = local.ansible_lab_vars.splunkbase_token
#     ansible_awx_password        = local.ansible_lab_vars.ansible_awx_password
#     ansible_awx_pg_password     = local.ansible_lab_vars.ansible_awx_pg_password
#     ansible_awx_secret_key      = local.ansible_lab_vars.ansible_awx_secret_key
#     lab_base_tld                = local.lab_base_tld
#     lab_base_name               = local.lab_base_name
#     win08_hosts                 = local.win08_hosts
#     win08_hosts_override        = local.win08_hosts_override
#     win10_hosts                 = local.win10_hosts
#     win10_hosts_override        = local.win10_hosts_override
#     win12_hosts                 = local.win12_hosts
#     win12_hosts_override        = local.win12_hosts_override
#     win16_hosts                 = local.win16_hosts
#     win16_hosts_override        = local.win16_hosts_override
#     win19_hosts                 = local.win19_hosts
#     win19_hosts_override        = local.win19_hosts_override
#     kali_hosts                  = local.kali_hosts
#     kali_hosts_override         = local.kali_hosts_override
#     centos_hosts                = local.centos_hosts
#     centos_hosts_override       = local.centos_hosts_override
#     ansible_hosts               = local.ansible_hosts
#     ansible_hosts_override      = local.ansible_hosts_override
#     aws_key_pair                = module.environment.key_pair
#     public_key_path             = local.public_key_path
#     ansible_group               = local.ansible_group
#     ansible_deployment_user     = local.ansible_deployment_user
#     ansible_deployment_group    = local.ansible_deployment_user
#     custom_security_groups      = local.custom_security_groups
#
#     splunk_user                 = local.splunk_user
#     ansible_user                = local.ansible_user
#     kali_user                   = local.kali_user
#     centos_user                 = local.centos_user
#     win08_user                  = local.win08_user
#     win10_user                  = local.win10_user
#     win12_user                  = local.win12_user
#     win16_user                  = local.win16_user
#     win19_user                  = local.win19_user
#     vault_passwd                = local.vault_passwd

# }

# # // add additional dns records internally
# # module "lab2_internal_dns" {
# #     module_name                 = "lab2_internal_dns"
# #     module_dependency       = module.lab2.module_complete

# #     source                      = "./modules/ec2_internal_dns_record"
# #     zone_id                     = module.lab2.internal_zone_id
# #     records                     =   [
# #                                         {
# #                                             name = "deployer"
# #                                             type = "CNAME"
# #                                             target = module.lab2.ansible_instances[0].private_dns
# #                                         }
# #                                     ]
# # }

# // add public dns records (in the format NAME.STUDENT_ID.PUBLIC_DOMAIN)
# module "lab2_public_dns_mapping" {
#     module_name                 =   "lab2_public_dns_mapping"
#     module_dependency           =   module.lab2.module_complete

#     source                      =   "./modules/ec2_public_dns_mapping"
#     public_domain               =   module.lab2.public_domain
#     vpc_id                      =   module.lab2.vpc_id
#     vpc_subnet                  =   module.lab2.vpc_subnet
#     subnet1_id                  =   module.lab2.subnet1_id
#     subnet2_id                  =   module.lab2.subnet2_id
#     student_id                  =   module.lab2.student_id
#     instances                   =   module.lab2.instances
#     subdomains                  =   local.public_dns_mapping
# }

# // copy over extended ansible setup
# module "lab2_files" {
#     module_name                 = "lab2_files"
#     module_dependency           = module.lab2.module_complete

#     source                  = "./modules/ec2_provision_file"
#     connection_settings     =   { 
#                                     host = module.lab2.ansible_instances[0].public_ip,
#                                     user = local.ansible_user, 
#                                     private_key = file(replace(local.public_key_path,".pub","")) 
#                                 }
#     files_copy              =   [
#                                     {
#                                         source = "/tmp/splunk.lic",
#                                         destination = "/tmp/splunk.lic"
#                                         type = "file"
#                                     },
#                                 ]
#     files_content           =   [
#                                     { 
#                                         content = templatefile("${path.root}/templates/ansible_domain_deployment.sh", local.ansible_lab_vars),
#                                         destination = "/home/${local.ansible_user}/ansible_domain_deployment.sh",
#                                         mode = 0755
#                                         type = "file"
#                                     },
#                                     { 
#                                         content = templatefile("${path.root}/templates/ansible_splunk_deployment.sh",  local.ansible_lab_vars),
#                                         destination = "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
#                                         mode = 0755
#                                         type = "file"
#                                     },
#                                 ]
# }

# # // execute extended ansible setup
# module "lab2_script_exec" {
#     module_name             = "lab2_script_exec"
#     module_dependency       = module.lab2_files.module_complete

#     source                  = "./modules/ec2_provision_script"
#     connection_settings     =   { 
#                                     host = module.lab2.ansible_instances[0].public_ip,
#                                     user = local.ansible_user, 
#                                     private_key = file(replace(local.public_key_path,".pub","")) 
#                                 }
#     inlines                 =   [
#                                     "/home/${local.ansible_user}/ansible_domain_deployment.sh",
#                                     "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
#                                 ]
#     scripts                 =   []
# }

# /*###############################################
# LAB 3
# ###############################################*/

# module "lab3" {
#     module_name                 = "lab3"
#     module_dependency           = module.environment.module_complete
#     source                      = "./modules/ec2_lab"
#     trusted_source              = local.trusted_source
#     kali_ami                    = local.kali_ami
#     win08_ami                   = local.win08_ami
#     win10_ami                   = local.win10_ami
#     win12_ami                   = local.win12_ami
#     win16_ami                   = local.win16_ami
#     win19_ami                   = local.win19_ami
#     centos_ami                  = local.centos_ami
#     aws_region                  = var.aws_region
#     project_prefix              = local.project_prefix
#     public_domain               = local.public_domain
#     internal_domain             = local.internal_domain
#     student_id                  = "lab3"
#     win_admin_user              = local.ansible_lab_vars.win_admin_user
#     win_admin_password          = local.ansible_lab_vars.win_admin_password
#     interal_domain              = local.ansible_lab_vars.interal_domain
#     win_netbios_domain          = local.ansible_lab_vars.win_netbios_domain
#     win_ca_common_name          = local.ansible_lab_vars.win_ca_common_name
#     splunk_password             = local.ansible_lab_vars.splunk_password
#     splunkbase_token            = local.ansible_lab_vars.splunkbase_token
#     ansible_awx_password        = local.ansible_lab_vars.ansible_awx_password
#     ansible_awx_pg_password     = local.ansible_lab_vars.ansible_awx_pg_password
#     ansible_awx_secret_key      = local.ansible_lab_vars.ansible_awx_secret_key
#     lab_base_tld                = local.lab_base_tld
#     lab_base_name               = local.lab_base_name
#     win08_hosts                 = local.win08_hosts
#     win08_hosts_override        = local.win08_hosts_override
#     win10_hosts                 = local.win10_hosts
#     win10_hosts_override        = local.win10_hosts_override
#     win12_hosts                 = local.win12_hosts
#     win12_hosts_override        = local.win12_hosts_override
#     win16_hosts                 = local.win16_hosts
#     win16_hosts_override        = local.win16_hosts_override
#     win19_hosts                 = local.win19_hosts
#     win19_hosts_override        = local.win19_hosts_override
#     kali_hosts                  = local.kali_hosts
#     kali_hosts_override         = local.kali_hosts_override
#     centos_hosts                = local.centos_hosts
#     centos_hosts_override       = local.centos_hosts_override
#     ansible_hosts               = local.ansible_hosts
#     ansible_hosts_override      = local.ansible_hosts_override
#     aws_key_pair                = module.environment.key_pair
#     public_key_path             = local.public_key_path
#     ansible_group               = local.ansible_group
#     ansible_deployment_user     = local.ansible_deployment_user
#     ansible_deployment_group    = local.ansible_deployment_user
#     custom_security_groups      = local.custom_security_groups
#
#     splunk_user                 = local.splunk_user
#     ansible_user                = local.ansible_user
#     kali_user                   = local.kali_user
#     centos_user                 = local.centos_user
#     win08_user                  = local.win08_user
#     win10_user                  = local.win10_user
#     win12_user                  = local.win12_user
#     win16_user                  = local.win16_user
#     win19_user                  = local.win19_user
#     vault_passwd                = local.vault_passwd
# }

# # // add additional dns records internally
# # module "lab3_internal_dns" {
# #     module_name                 = "lab3_internal_dns"
# #     module_dependency       = module.lab3.module_complete

# #     source                      = "./modules/ec2_internal_dns_record"
# #     zone_id                     = module.lab3.internal_zone_id
# #     records                     =   [
# #                                         {
# #                                             name = "deployer"
# #                                             type = "CNAME"
# #                                             target = module.lab3.ansible_instances[0].private_dns
# #                                         }
# #                                     ]
# # }

# // add public dns records (in the format NAME.STUDENT_ID.PUBLIC_DOMAIN)
# module "lab3_public_dns_mapping" {
#     module_name                 =   "lab3_public_dns_mapping"
#     module_dependency           =   module.lab3.module_complete

#     source                      =   "./modules/ec2_public_dns_mapping"
#     public_domain               =   module.lab3.public_domain
#     vpc_id                      =   module.lab3.vpc_id
#     vpc_subnet                  =   module.lab3.vpc_subnet
#     subnet1_id                  =   module.lab3.subnet1_id
#     subnet2_id                  =   module.lab3.subnet2_id
#     student_id                  =   module.lab3.student_id
#     instances                   =   module.lab3.instances
#     subdomains                  =   local.public_dns_mapping
# }

# // copy over extended ansible setup
# module "lab3_files" {
#     module_name                 = "lab3_files"
#     module_dependency           = module.lab3.module_complete

#     source                  = "./modules/ec2_provision_file"
#     connection_settings     =   { 
#                                     host = module.lab3.ansible_instances[0].public_ip,
#                                     user = local.ansible_user, 
#                                     private_key = file(replace(local.public_key_path,".pub","")) 
#                                 }
#     files_copy              =   [
#                                     {
#                                         source = "/tmp/splunk.lic",
#                                         destination = "/tmp/splunk.lic"
#                                         type = "file"
#                                     },
#                                 ]
#     files_content           =   [
#                                     { 
#                                         content = templatefile("${path.root}/templates/ansible_domain_deployment.sh", local.ansible_lab_vars),
#                                         destination = "/home/${local.ansible_user}/ansible_domain_deployment.sh",
#                                         mode = 0755
#                                         type = "file"
#                                     },
#                                     { 
#                                         content = templatefile("${path.root}/templates/ansible_splunk_deployment.sh",  local.ansible_lab_vars),
#                                         destination = "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
#                                         mode = 0755
#                                         type = "file"
#                                     },
#                                 ]
# }

# # // execute extended ansible setup
# module "lab3_script_exec" {
#     module_name             = "lab3_script_exec"
#     module_dependency       = module.lab3_files.module_complete

#     source                  = "./modules/ec2_provision_script"
#     connection_settings     =   { 
#                                     host = module.lab3.ansible_instances[0].public_ip,
#                                     user = local.ansible_user, 
#                                     private_key = file(replace(local.public_key_path,".pub","")) 
#                                 }
#     inlines                 =   [
#                                     "/home/${local.ansible_user}/ansible_domain_deployment.sh",
#                                     "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
#                                 ]
#     scripts                 =   []
# }

# /*###############################################
# LAB 4
# ###############################################*/

# module "lab4" {
#     module_name                 = "lab4"
#     module_dependency           = module.environment.module_complete
#     source                      = "./modules/ec2_lab"
#     trusted_source              = local.trusted_source
#     kali_ami                    = local.kali_ami
#     win08_ami                   = local.win08_ami
#     win10_ami                   = local.win10_ami
#     win12_ami                   = local.win12_ami
#     win16_ami                   = local.win16_ami
#     win19_ami                   = local.win19_ami
#     centos_ami                  = local.centos_ami
#     aws_region                  = var.aws_region
#     project_prefix              = local.project_prefix
#     public_domain               = local.public_domain
#     internal_domain             = local.internal_domain
#     student_id                  = "lab4"
#     win_admin_user              = local.ansible_lab_vars.win_admin_user
#     win_admin_password          = local.ansible_lab_vars.win_admin_password
#     interal_domain              = local.ansible_lab_vars.interal_domain
#     win_netbios_domain          = local.ansible_lab_vars.win_netbios_domain
#     win_ca_common_name          = local.ansible_lab_vars.win_ca_common_name
#     splunk_password             = local.ansible_lab_vars.splunk_password
#     splunkbase_token            = local.ansible_lab_vars.splunkbase_token
#     ansible_awx_password        = local.ansible_lab_vars.ansible_awx_password
#     ansible_awx_pg_password     = local.ansible_lab_vars.ansible_awx_pg_password
#     ansible_awx_secret_key      = local.ansible_lab_vars.ansible_awx_secret_key
#     lab_base_tld                = local.lab_base_tld
#     lab_base_name               = local.lab_base_name
#     win08_hosts                 = local.win08_hosts
#     win08_hosts_override        = local.win08_hosts_override
#     win10_hosts                 = local.win10_hosts
#     win10_hosts_override        = local.win10_hosts_override
#     win12_hosts                 = local.win12_hosts
#     win12_hosts_override        = local.win12_hosts_override
#     win16_hosts                 = local.win16_hosts
#     win16_hosts_override        = local.win16_hosts_override
#     win19_hosts                 = local.win19_hosts
#     win19_hosts_override        = local.win19_hosts_override
#     kali_hosts                  = local.kali_hosts
#     kali_hosts_override         = local.kali_hosts_override
#     centos_hosts                = local.centos_hosts
#     centos_hosts_override       = local.centos_hosts_override
#     ansible_hosts               = local.ansible_hosts
#     ansible_hosts_override      = local.ansible_hosts_override
#     aws_key_pair                = module.environment.key_pair
#     public_key_path             = local.public_key_path
#     ansible_group               = local.ansible_group
#     ansible_deployment_user     = local.ansible_deployment_user
#     ansible_deployment_group    = local.ansible_deployment_user
#     custom_security_groups      = local.custom_security_groups
#
#     splunk_user                 = local.splunk_user
#     ansible_user                = local.ansible_user
#     kali_user                   = local.kali_user
#     centos_user                 = local.centos_user
#     win08_user                  = local.win08_user
#     win10_user                  = local.win10_user
#     win12_user                  = local.win12_user
#     win16_user                  = local.win16_user
#     win19_user                  = local.win19_user
#     vault_passwd                = local.vault_passwd
# }

# # // add additional dns records internally
# # module "lab4_internal_dns" {
# #     module_name                 = "lab4_internal_dns"
# #     module_dependency       = module.lab4.module_complete

# #     source                      = "./modules/ec2_internal_dns_record"
# #     zone_id                     = module.lab4.internal_zone_id
# #     records                     =   [
# #                                         {
# #                                             name = "deployer"
# #                                             type = "CNAME"
# #                                             target = module.lab4.ansible_instances[0].private_dns
# #                                         }
# #                                     ]
# # }

# // add public dns records (in the format NAME.STUDENT_ID.PUBLIC_DOMAIN)
# module "lab4_public_dns_mapping" {
#     module_name                 =   "lab4_public_dns_mapping"
#     module_dependency           =   module.lab4.module_complete

#     source                      =   "./modules/ec2_public_dns_mapping"
#     public_domain               =   module.lab4.public_domain
#     vpc_id                      =   module.lab4.vpc_id
#     vpc_subnet                  =   module.lab4.vpc_subnet
#     subnet1_id                  =   module.lab4.subnet1_id
#     subnet2_id                  =   module.lab4.subnet2_id
#     student_id                  =   module.lab4.student_id
#     instances                   =   module.lab4.instances
#     subdomains                  =   local.public_dns_mapping
# }

# // copy over extended ansible setup
# module "lab4_files" {
#     module_name                 = "lab4_files"
#     module_dependency           = module.lab4.module_complete

#     source                  = "./modules/ec2_provision_file"
#     connection_settings     =   { 
#                                     host = module.lab4.ansible_instances[0].public_ip,
#                                     user = local.ansible_user, 
#                                     private_key = file(replace(local.public_key_path,".pub","")) 
#                                 }
#     files_copy              =   [
#                                     {
#                                         source = "/tmp/splunk.lic",
#                                         destination = "/tmp/splunk.lic"
#                                         type = "file"
#                                     },
#                                 ]
#     files_content           =   [
#                                     { 
#                                         content = templatefile("${path.root}/templates/ansible_domain_deployment.sh", local.ansible_lab_vars),
#                                         destination = "/home/${local.ansible_user}/ansible_domain_deployment.sh",
#                                         mode = 0755
#                                         type = "file"
#                                     },
#                                     { 
#                                         content = templatefile("${path.root}/templates/ansible_splunk_deployment.sh",  local.ansible_lab_vars),
#                                         destination = "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
#                                         mode = 0755
#                                         type = "file"
#                                     },
#                                 ]
# }

# # // execute extended ansible setup
# module "lab4_script_exec" {
#     module_name             = "lab4_script_exec"
#     module_dependency       = module.lab4_files.module_complete

#     source                  = "./modules/ec2_provision_script"
#     connection_settings     =   { 
#                                     host = module.lab4.ansible_instances[0].public_ip,
#                                     user = local.ansible_user, 
#                                     private_key = file(replace(local.public_key_path,".pub","")) 
#                                 }
#     inlines                 =   [
#                                     "/home/${local.ansible_user}/ansible_domain_deployment.sh",
#                                     "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
#                                 ]
#     scripts                 =   []
# }

# /*###############################################
# LAB 5
# ###############################################*/

# module "lab5" {
#     module_name                 = "lab5"
#     module_dependency           = module.environment.module_complete
#     source                      = "./modules/ec2_lab"
#     trusted_source              = local.trusted_source
#     kali_ami                    = local.kali_ami
#     win08_ami                   = local.win08_ami
#     win10_ami                   = local.win10_ami
#     win12_ami                   = local.win12_ami
#     win16_ami                   = local.win16_ami
#     win19_ami                   = local.win19_ami
#     centos_ami                  = local.centos_ami
#     aws_region                  = var.aws_region
#     project_prefix              = local.project_prefix
#     public_domain               = local.public_domain
#     internal_domain             = local.internal_domain
#     student_id                  = "lab5"
#     win_admin_user              = local.ansible_lab_vars.win_admin_user
#     win_admin_password          = local.ansible_lab_vars.win_admin_password
#     interal_domain              = local.ansible_lab_vars.interal_domain
#     win_netbios_domain          = local.ansible_lab_vars.win_netbios_domain
#     win_ca_common_name          = local.ansible_lab_vars.win_ca_common_name
#     splunk_password             = local.ansible_lab_vars.splunk_password
#     splunkbase_token            = local.ansible_lab_vars.splunkbase_token
#     ansible_awx_password        = local.ansible_lab_vars.ansible_awx_password
#     ansible_awx_pg_password     = local.ansible_lab_vars.ansible_awx_pg_password
#     ansible_awx_secret_key      = local.ansible_lab_vars.ansible_awx_secret_key
#     lab_base_tld                = local.lab_base_tld
#     lab_base_name               = local.lab_base_name
#     win08_hosts                 = local.win08_hosts
#     win08_hosts_override        = local.win08_hosts_override
#     win10_hosts                 = local.win10_hosts
#     win10_hosts_override        = local.win10_hosts_override
#     win12_hosts                 = local.win12_hosts
#     win12_hosts_override        = local.win12_hosts_override
#     win16_hosts                 = local.win16_hosts
#     win16_hosts_override        = local.win16_hosts_override
#     win19_hosts                 = local.win19_hosts
#     win19_hosts_override        = local.win19_hosts_override
#     kali_hosts                  = local.kali_hosts
#     kali_hosts_override         = local.kali_hosts_override
#     centos_hosts                = local.centos_hosts
#     centos_hosts_override       = local.centos_hosts_override
#     ansible_hosts               = local.ansible_hosts
#     ansible_hosts_override      = local.ansible_hosts_override
#     aws_key_pair                = module.environment.key_pair
#     public_key_path             = local.public_key_path
#     ansible_group               = local.ansible_group
#     ansible_deployment_user     = local.ansible_deployment_user
#     ansible_deployment_group    = local.ansible_deployment_user
#     custom_security_groups      = local.custom_security_groups
#
#     splunk_user                 = local.splunk_user
#     ansible_user                = local.ansible_user
#     kali_user                   = local.kali_user
#     centos_user                 = local.centos_user
#     win08_user                  = local.win08_user
#     win10_user                  = local.win10_user
#     win12_user                  = local.win12_user
#     win16_user                  = local.win16_user
#     win19_user                  = local.win19_user
#     vault_passwd                = local.vault_passwd
# }

# # // add additional dns records internally
# # module "lab5_internal_dns" {
# #     module_name                 = "lab5_internal_dns"
# #     module_dependency       = module.lab5.module_complete

# #     source                      = "./modules/ec2_internal_dns_record"
# #     zone_id                     = module.lab5.internal_zone_id
# #     records                     =   [
# #                                         {
# #                                             name = "deployer"
# #                                             type = "CNAME"
# #                                             target = module.lab5.ansible_instances[0].private_dns
# #                                         }
# #                                     ]
# # }

# // add public dns records (in the format NAME.STUDENT_ID.PUBLIC_DOMAIN)
# module "lab5_public_dns_mapping" {
#     module_name                 =   "lab5_public_dns_mapping"
#     module_dependency           =   module.lab5.module_complete

#     source                      =   "./modules/ec2_public_dns_mapping"
#     public_domain               =   module.lab5.public_domain
#     vpc_id                      =   module.lab5.vpc_id
#     vpc_subnet                  =   module.lab5.vpc_subnet
#     subnet1_id                  =   module.lab5.subnet1_id
#     subnet2_id                  =   module.lab5.subnet2_id
#     student_id                  =   module.lab5.student_id
#     instances                   =   module.lab5.instances
#     subdomains                  =   local.public_dns_mapping
# }

# // copy over extended ansible setup
# module "lab5_files" {
#     module_name                 = "lab5_files"
#     module_dependency           = module.lab5.module_complete

#     source                  = "./modules/ec2_provision_file"
#     connection_settings     =   { 
#                                     host = module.lab5.ansible_instances[0].public_ip,
#                                     user = local.ansible_user, 
#                                     private_key = file(replace(local.public_key_path,".pub","")) 
#                                 }
#     files_copy              =   [
#                                     {
#                                         source = "/tmp/splunk.lic",
#                                         destination = "/tmp/splunk.lic"
#                                         type = "file"
#                                     },
#                                 ]
#     files_content           =   [
#                                     { 
#                                         content = templatefile("${path.root}/templates/ansible_domain_deployment.sh", local.ansible_lab_vars),
#                                         destination = "/home/${local.ansible_user}/ansible_domain_deployment.sh",
#                                         mode = 0755
#                                         type = "file"
#                                     },
#                                     { 
#                                         content = templatefile("${path.root}/templates/ansible_splunk_deployment.sh",  local.ansible_lab_vars),
#                                         destination = "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
#                                         mode = 0755
#                                         type = "file"
#                                     },
#                                 ]
# }

# # // execute extended ansible setup
# module "lab5_script_exec" {
#     module_name             = "lab5_script_exec"
#     module_dependency       = module.lab5_files.module_complete

#     source                  = "./modules/ec2_provision_script"
#     connection_settings     =   { 
#                                     host = module.lab5.ansible_instances[0].public_ip,
#                                     user = local.ansible_user, 
#                                     private_key = file(replace(local.public_key_path,".pub","")) 
#                                 }
#     inlines                 =   [
#                                     "/home/${local.ansible_user}/ansible_domain_deployment.sh",
#                                     "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
#                                 ]
#     scripts                 =   []
# }