variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable connection_settings {
    description = "connection settings"
}

variable "files_content" {
    description = "content and destination list"
    default = []
}

variable "files_copy" {
    description = "source and destination list"
    default = []
}