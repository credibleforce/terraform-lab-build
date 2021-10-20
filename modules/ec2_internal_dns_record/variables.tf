
variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable zone_id {
    description = "dns zone id"
}

variable records {
    description = "A list of records - name, type, target"
    default = []
}