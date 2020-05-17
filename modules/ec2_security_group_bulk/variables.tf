
variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable security_groups {
    description = "list of security groups (name, inbound_ports.source_port, inbound_ports.destination_port, inbound_ports.protocol)"
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