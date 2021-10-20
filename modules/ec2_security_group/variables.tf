
variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable security_group_name {
    description = "security group name"
}

variable inbound_ports {
    description = "inbound ports (source_port, destination_port, protocol)"
    default = []
}

variable trusted_source {
    description = "trusted source network"
}

variable vpc_id {
    description =  "vpc id"
}

variable vpc_subnet {
    description = "vpc_subnet"
}