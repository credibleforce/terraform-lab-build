variable "module_name" {
}

variable "instances" {
  description = "ELB instances, name, cert (bool to enable/disable certificate assignment), certificate (certificate id), security group (security group id), port_mapping (src_port, dest_port, target_ip)"
  default = []
}

variable "module_dependency" {
  default = ""
}