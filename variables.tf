variable "aws_region" {
    description = "AWS region to launch servers."
    default     = "us-east-1"
}

variable "lab_base_name" {
    description = "internal name for the lab"
}

variable "lab_base_tld" {
    description = "internal tld for the lab"
}

variable "win_user" {
    description = "windows admin user"
}

variable "win_password" {
    description = "windows admin password"
}

variable "splunk_password" {
    description = "splunk password"
}

variable "ansible_awx_password" {
    description = "awx password"
}

variable "ansible_awx_pg_password" {
    description = "awx pg password"
}

variable "ansible_awx_secret_key" {
    description = "awx secret key"
}


