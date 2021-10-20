variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable public_domain {
    description = "public domain name"
}

variable subdomains {
    description  = "subdomains to configure, name (string), type (string - e.g. CNAME, A), target (string array)"
    default = []
}