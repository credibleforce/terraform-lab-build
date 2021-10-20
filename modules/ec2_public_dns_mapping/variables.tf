variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable public_domain {
    description = "public domain name"
}

variable student_id {
  description = "student id"
}

variable vpc_id {
  description = "vpc id"
}

variable vpc_subnet {
  description = "vpc subnet"
}

variable subnet1_id {
  description = "subnet1 id"
}

variable subnet2_id {
  description = "subnet2 id"
}

variable instances {
  description = "deployed ec2 instances"
}

variable subdomains {
    description  = "subdomains to configure, name (string), cert (bool) targets (ec2 instance names to map dns to), elb (bool), elb_port_map (source, source_port, destination_port, protocol) "
    default = []
}