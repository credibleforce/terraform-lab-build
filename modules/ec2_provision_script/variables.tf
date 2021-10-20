variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable connection_settings {
    description = "connection settings"
}

variable scripts {
    description = "list of scripts to execute"
    default = []
}

variable inlines {
    description = "array of inline commands"
    default = []
}