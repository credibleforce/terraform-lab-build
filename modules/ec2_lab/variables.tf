
variable "module_name" {
}

variable "module_dependency" {
  default = ""
}

variable "aws_region" {
    description = "AWS region to launch servers."
    default     = "us-east-1"
}

variable "project_prefix" {
    description = "Name to prepend to resources linked to this project"
    default     = "tf-testing"
}

variable "public_key_path" {
    description = "Path to public key used for authentication"
    default = "~/.ssh/id_rsa.pub"
}

variable "trusted_source" {
  description = "Trusted source network (e.g. x.x.x.x/32)"
  default = "0.0.0.0/0"
}

variable "kali_hosts" {
  description = "Number of hosts"
  default     = 0
}

variable "kali_hosts_override" {
    description = "Override default hostname and tagging for hosts. Host count will be equal to number of overrides provided."
    default = []
}

variable "win10_hosts" {
  description = "Number of hosts"
  default     = 0
}

variable "win10_hosts_override" {
    description = "Override default hostname and tagging for hosts. Host count will be equal to number of overrides provided."
    default = []
}

variable "win16_hosts" {
  description = "Number of hosts"
  default     = 0
}

variable "win16_hosts_override" {
    description = "Override default hostname and tagging for hosts. Host count will be equal to number of overrides provided."
    default = []
}

variable "ansible_hosts" {
  description = "Number of hosts"
  default     = 1
}
variable "ansible_hosts_override" {
    description = "Override default hostname and tagging for hosts. Host count will be equal to number of overrides provided."
    default = []
}

variable "centos_hosts" {
  description = "Number of hosts"
  default     = 0
}

variable "centos_hosts_override" {
    description = "Override default hostname and tagging for hosts. Host count will be equal to number of overrides provided."
    default = []
}

variable "vpc_subnet" {
  description = "Number of hosts"
  default     = "172.16.0.0/16"
}

variable "subnet1_az" {
  description = <<DESCRIPTION
Network subnet1 availability zone (e.g. us-east-1a)
  DESCRIPTION
  default = "us-east-1a"
}

variable "subnet2_az" {
  description = <<DESCRIPTION
Network subnet2 availability zone (e.g. us-east-1f)
  DESCRIPTION
  default = "us-east-1f"
}

variable win_user {
    description = "windows connection username"
    default = "administrator"
}

variable win_password {
    description = "windows connection password"
    default = "myTempPassword123"
}

variable ansible_deployment_user {
    description = "ansible deployment user"
    default = "deployer"
}

variable ansible_deployment_group {
    description = "ansible deployment group"
    default = "deployer"
}

variable internal_domain {
    description = "internal/private dns domain"
}

variable public_domain {
    description = "public dns domain"
}

variable student_id {
    description = "student id"
    default = "1"
}

variable kali_ami {
    description = "kali ami"
}

variable win10_ami {
    description = "win10 ami"
}

variable win16_ami {
    description = "win16 ami"
}
variable centos_ami {
    description = "centos ami"
}

variable aws_key_pair {
    description = "aws_key_pair"
}

variable ansible_user {
    description = "ansible user is the account used to make the initial connect to the ec2 host. context for ongoing deployment is switched to ansible_deployment_user"
    default = "centos"
}

variable ansible_group {
    description = "ansible group of the ansible_user above. context for ongoing deployment is switched to ansible_deployment_user and ansible_deployment_group"
    default = "centos"
}

variable custom_security_groups {
    description = "list of security groups (name, inbound_ports.source_port, inbound_ports.destination_port, inbound_ports.protocol)"
    default = []
}