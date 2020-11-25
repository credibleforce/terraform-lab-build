variable "aws_region" {
    description = "AWS region to launch servers."
    default     = "us-east-1"
}

variable "lab_base_tld" {
    description = "internal tld for the lab"
    default     = "lan"
}


variable "lab_base_name" {
    description = "internal name for the lab"
    default     = "lab"
}

variable "internal_domain" {
    description = "internal dns name for the lab"
    default     = join(".", var.lab_base_name, var.lab_base_tld
}


