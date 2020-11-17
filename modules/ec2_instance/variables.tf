variable "module_name" {
}

variable "module_dependency" {
  default = ""
}
variable host_count {
    description = "number of hosts to provision"
}

variable hosts_override {
    description = "override default hostname. if provided this will take precendence over host_count."
}

variable host_prefix {
    description = "hostname prefix"
}

variable host_role {
    description = "ansible role tagged in ec2 instance"
}

variable internal_domain {
    description = "internal domain"
}

variable instance_type {
    description = "instance type"
}

variable image_id {
    description = "image id"
}

variable volume_size {
    description = "volume size"
}

variable security_group_id {
    description = "security group id"
}

variable key_id {
    description = "aws auth key id"
}

variable subnet_id {
    description = "subnet id"
}

variable subnet_prefix {
    description = "subnet prefix"
}

variable last_octet_base {
    description = "last octet base"
}

variable zone_id {
    description = "dns zone id"
}

variable provisioning_file {
    description = "provisioning_file"
}

variable win_user {
    description = "windows username"
    default = "administrator"
}

variable win_password {
    description = "windows password"
    default = ""
    
}

variable connection_settings {
    description = "connection settings"
}

variable custom_security_groups {
    description = "custom security groups"
    default = []
}

variable student_id {
    description = "student id"
}