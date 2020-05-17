
locals {
    project_prefix              = "pslab"
    internal_domain             = "pslab.local"
    public_domain               = "proserv-cloud.com"
    win10_ami                   = "ami-0f9a8c9a37595c698"
    win16_ami                   = data.aws_ami.win16.image_id
    centos_ami                  = data.aws_ami.centos.image_id
    kali_ami                    = data.aws_ami.kali.image_id
    trusted_source              = trimspace(data.local_file.trusted-source.content)
    win_user                    = "administrator"
    win_password                = "myTempPassword123"
    win10_hosts                 = 0
    win10_hosts_override        = []
    # win10_hosts_override        =   [
    #                                     {name="win10-dsk1", role="member_server"},
    #                                 ]
    win16_hosts                 = 0
    win16_hosts_override        = []
    # win16_hosts_override        =   [
    #                                     {name="win16-dc1", role="domain_controller,certificate_authority,splunk_universal_forwarder"},
    #                                     {name="win16-wef1", role="wef_server,splunk_universal_forwarder"},
    #                                     {name="win16-svr1", role="member_server"},
    #                                 ]
    kali_hosts                  = 0
    kali_hosts_override         = []
    centos_hosts                = 0
    centos_hosts_override       =   [
                                        {name="splk-sh1", role="splunk_search_head,splunk_deployment_server", custom_security_group="splunk_security_group"},
                                        #{name="splk-lm1", role="splunk_license_master", custom_security_group="splunk_security_group"},
                                        #{name="splk-dp1", role="splunk_deployment_server", custom_security_group="splunk_security_group"},
                                        #{name="splk-cm1", role="splunk_cluster_master", custom_security_group="splunk_security_group"},
                                        #{name="splk-sdp1", role="splunk_deployer", custom_security_group="splunk_security_group"},
                                        {name="splk-idx1", role="splunk_indexer", custom_security_group="splunk_security_group"},
                                        #{name="splk-idx2", role="splunk_indexer", custom_security_group="splunk_security_group"},
                                        {name="splk-uf1", role="splunk_universal_forwarder", custom_security_group="splunk_security_group"},
                                    ]
    ansible_user                = "centos"
    ansible_group               = "centos"
    ansible_deployment_user     = "deployer"
    ansible_deployment_group    = "deployer"
    ansible_hosts               = 1
    ansible_hosts_override      =   [
                                        #{name="ansible1", custom_security_group="splunk_security_group"},
                                    ]
    ansible_private_dns         = length(module.lab1.ansible_hosts)>0? module.lab1.ansible_hosts[0].private_dns : null
    ansible_public_ip           = length(module.lab1.ansible_hosts)>0? module.lab1.ansible_hosts[0].public_ip : null
    
    custom_security_groups      =   [
                                        { name="splunk_security_group", inbound_ports=  [ 
                                                                                            { source_port=22,destination_port=22,protocol="tcp" },
                                                                                            { source_port=443,destination_port=443,protocol="tcp" },
                                                                                            { source_port=8000,destination_port=8000,protocol="tcp" },
                                                                                            { source_port=8089,destination_port=8089,protocol="tcp" },
                                                                                            { source_port=9997,destination_port=9997,protocol="tcp" },
                                                                                            { source_port=9998,destination_port=9998,protocol="tcp" },
                                                                                        ]
                                        }
                                    ]
    
    key_name                    = "${local.project_prefix}-key"
    public_key_path             = "~/.ssh/id_rsa.pub"

    ansible_lab_vars = {
        win_dns_domain          = local.internal_domain
        win_netbios_domain      = "PSLAB"
        win_admin_user          = local.win_user
        win_admin_password      = local.win_password
        win_ca_common_name      = "PKI"
    }
}

module "environment" {
    module_name                 = "environment"
    source                      = "./environments/dev"
    key_name                    = local.key_name
    public_key_path             = local.public_key_path
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
    win10_ami                   = local.win10_ami
    win16_ami                   = local.win16_ami
    centos_ami                  = local.centos_ami
    aws_region                  = var.aws_region
    project_prefix              = local.project_prefix
    public_domain               = local.public_domain
    internal_domain             = local.internal_domain
    student_id                  = "s001"
    win_user                    = local.win_user
    win_password                = local.win_password
    win10_hosts                 = local.win10_hosts
    win10_hosts_override        = local.win10_hosts_override
    win16_hosts                 = local.win16_hosts
    win16_hosts_override        = local.win16_hosts_override
    kali_hosts                  = local.kali_hosts
    kali_hosts_override         = local.kali_hosts_override
    centos_hosts                = local.centos_hosts
    centos_hosts_override       = local.centos_hosts_override
    ansible_hosts               = local.ansible_hosts
    ansible_hosts_override      = local.ansible_hosts_override
    aws_key_pair                = module.environment.key_pair
    public_key_path             = local.public_key_path
    ansible_user                = local.ansible_user
    ansible_group               = local.ansible_group
    ansible_deployment_user     = local.ansible_deployment_user
    ansible_deployment_group    = local.ansible_deployment_user
    custom_security_groups      = local.custom_security_groups
}

# // add additional dns records internally
# module "lab1_internal_dns" {
#     module_name                 = "lab1_internal_dns"
#     module_dependency       = module.lab1.module_complete

#     source                      = "./modules/ec2_internal_dns_record"
#     zone_id                     = module.lab1.internal_zone_id
#     records                     =   [{
#                                     name = "deployer"
#                                     type = "CNAME"
#                                     target = local.ansible_private_dns
#                                     }]
# }

# // add public dns records
# module "lab1_public_dns" {
#     module_name                 = "lab1_public_dns"
#     module_dependency           = module.lab1_internal_dns.module_complete

#     source                      = "./modules/ec2_public_dns"
#     public_domain               = local.public_domain
#     subdomains                  =   [{
#                                         name = format("%s-deployer-%s", local.project_prefix, module.lab1.student_id) 
#                                         type = "A"
#                                         target = local.ansible_public_ip
#                                         cert = false
#                                     }]
# }

// copy over extended ansible setup
module "lab1_files" {
    module_name                 = "lab1_files"
    module_dependency           = module.lab1.module_complete

    source                  = "./modules/ec2_provision_file"
    connection_settings     =   { 
                                    host = local.ansible_public_ip,
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
                                    # { 
                                    #     content = templatefile("${path.root}/templates/ansible_domain_deployment.sh", local.ansible_lab_vars),
                                    #     destination = "/home/${local.ansible_user}/ansible_domain_deployment.sh",
                                    #     mode = 0755
                                    #     type = "file"
                                    # },
                                    { 
                                        content = file("${path.root}/templates/ansible_splunk_deployment.sh"),
                                        destination = "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
                                        mode = 0755
                                        type = "file"
                                    },
                                ]
}

// execute extended ansible setup
module "lab1_script_exec" {
    module_name             = "lab1_script_exec"
    module_dependency       = module.lab1_files.module_complete

    source                  = "./modules/ec2_provision_script"
    connection_settings     =   { 
                                    host = local.ansible_public_ip,
                                    user = local.ansible_user, 
                                    private_key = file(replace(local.public_key_path,".pub","")) 
                                }
    inlines                 =   [
                                    #"/home/${local.ansible_user}/ansible_domain_deployment.sh",
                                    "/home/${local.ansible_user}/ansible_splunk_deployment.sh",
                                ]
    scripts                 =   []
}

/*###############################################
LAB 2
###############################################*/

# module "lab2" {
#     module_name               = "lab2"
#     module_dependency           = module.environment.module_complete
#     source                    = "./modules/ec2_lab"
#
#     trusted_source            = local.trusted_source
#     kali_ami                  = local.kali_ami
#     win10_ami                 = local.win10_ami
#     win16_ami                 = local.win16_ami
#     centos_ami                = local.centos_ami
#     aws_region                = var.aws_region
#     project_prefix            = local.project_prefix
#     public_domain             = local.public_domain
#     internal_domain           = local.internal_domain
#     student_id                = "s002"
#     win10_hosts               = local.win10_hosts
#     win16_hosts               = local.win16_hosts
#     kali_hosts                = local.kali_hosts
#     centos_hosts              = local.centos_hosts
#     centos_hostname_override  = ["splksh1","splkdp1"]
#     ansible_hosts             = local.ansible_hosts
#     aws_key_pair              = module.environment.key_pair
#     public_key_path           = local.public_key_path
# }

# // add additional dns records internally
# module "lab2_internal_dns" {
#     source                  = "./modules/ec2_internal_dns_record"
#     zone_id                 = module.lab2.internal_zone_id
#     records                 =   [{
#                                     name = "deployer"
#                                     type = "CNAME"
#                                     target = local.ansible_private_dns
#                                 }]
#     depends_variable        =   module.lab2
# }

# // add public dns records
# module "lab2_public_dns" {
#     source                  = "./modules/ec2_public_dns"
#     public_domain           = local.public_domain
#     subdomains              =   [{
#                                     name = format("%s-deployer-%s", local.project_prefix, module.lab2.student_id) 
#                                     type = "A"
#                                     target = local.ansible_public_ip
#                                     cert = false
#                                 }]
#     depends_variable        =   module.lab2
# }

