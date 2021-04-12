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

variable "win_admin_user" {
    description = "windows admin user"
}

variable "win_admin_password" {
    description = "windows admin password"
}

variable "splunk_password" {
    description = "splunk password"
}

variable "splunkbase_token" {
    description = "splunkbase token"
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

variable "vault_passwd" {
    description = "ansible vault password"
}

variable "public_domain" {
    description = "public domain used for external service hosting"
}

variable "win08_ami" {
    description = "aws ami image for win08"
}

variable "win10_ami" {
    description = "aws ami image for win10"
}

variable "win08_user" {
    description = "win08 user"
}

variable "win10_user" {
    description = "win10 user"
}

variable "win12_user" {
    description = "win12 user"
}

variable "win16_user" {
    description = "win16 user"
}

variable "win19_user" {
    description = "win19 user"
}

variable "ansible_user" {
    description = "ansible user"
}

variable "kali_user" {
    description = "kali user"
}

variable "centos_user" {
    description = "centos user"
}

variable "splunk_user" {
    description = "splunk user"
}

