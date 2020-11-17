variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable public_domain {
    description = "public domain name"
}

variable subdomains {
    description  = "list of subdomains to issue certificates for"
    default = []
}