variable "module_name" {
}

variable "module_dependency" {
  default = ""
}
variable "internal_domain" {
    description = "internal/private domain name"
}

variable "vpc_id" {
    description = "id of vpc to attach to"
}