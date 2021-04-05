#!/bin/bash

# rm -rf domain-deployment
# mkdir domain-deployment
# cd domain-deployment
# git clone --recurse-submodules --single-branch --branch 'develop' https://github.com/mobia-security-services/splunk-lab
# cd splunk-lab
# cd ansible

# export WIN_DNS_DOMAIN="${win_dns_domain}" WIN_NETBIOS_DOMAIN="${win_netbios_domain}" WIN_ADMIN_PASSWORD="${win_admin_password}" WIN_ADMIN_USER=${win_admin_user} WIN_CA_COMMON_NAME="${win_ca_common_name}"

# ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/build-env.yml --extra-vars @~/deployment/ansible/vars_base.yml

# setup domain
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password="${ansible_awx_password}" --conf.insecure job_templates launch 'lab-template' --monitor -f human --extra-vars "@vars_base.yml"