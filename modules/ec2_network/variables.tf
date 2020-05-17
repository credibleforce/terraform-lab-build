variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable vpc_name {
    description = "vpc name"
}
variable vpc_subnet {
    description = "vpc subnet"
}

variable igw_name {
    description = "internet gateway name"
}

variable subnet1_name {
    description =  "primary subnet name"
}

variable subnet1_prefix {
    description = "primary subnet prefix"
}

variable subnet1_az {
    description = "primary subnet availability zone"
}

variable subnet2_name {
    description =  "secondary subnet name"
}

variable subnet2_prefix {
    description = "secondary subnet prefix"
}

variable subnet2_az {
    description = "secondary subnet availability zone"
}