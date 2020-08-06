#!/bin/bash

rm -rf domain-deployment
mkdir domain-deployment
source ./ansible/hacking/env-setup
cd domain-deployment
git clone --single-branch --branch 'develop' https://github.com/mobia-security-services/splunk-lab
cd splunk-lab
cd ansible

export WIN_DNS_DOMAIN="${win_dns_domain}" WIN_NETBIOS_DOMAIN="${win_netbios_domain}" WIN_ADMIN_PASSWORD="${win_admin_password}" WIN_ADMIN_USER=${win_admin_user} WIN_CA_COMMON_NAME="${win_ca_common_name}"

ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/build-env.yml --extra-vars @~/deployment/ansible/vars_base.yml