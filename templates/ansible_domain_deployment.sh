#!/bin/bash

# rm -rf domain-deployment
# mkdir domain-deployment
# cd domain-deployment
# git clone --recurse-submodules --single-branch --branch 'develop' https://github.com/mobia-security-services/splunk-lab
# cd splunk-lab
# cd ansible

# export WIN_DNS_DOMAIN="${win_dns_domain}" WIN_NETBIOS_DOMAIN="${win_netbios_domain}" WIN_ADMIN_PASSWORD="${win_admin_password}" WIN_ADMIN_USER=${win_admin_user} WIN_CA_COMMON_NAME="${win_ca_common_name}"

# ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/build-env.yml --extra-vars @~/deployment/ansible/vars_base.yml

# sync splunk repo
sudo mkdir /opt/repo
sudo git clone --branch develop --recursive https://github.com/mobia-security-services/splunk-lab /opt/repo/splunk-lab

# sym link doesn't work (needs further test) just copy ansible directory - ideally structure of repo include ansible.cfg at the root for awx
sudo mkdir -p /opt/awx/projects \
    && sudo cp -pr /opt/repo/splunk-lab/ansible /opt/awx/projects/lab

# create a lab project
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password="${ansible_awx_password}" --conf.insecure project create --name "lab-project" --organization "lab" --scm_type "" --local_path "lab"

# create lab job template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password="${ansible_awx_password}" --conf.insecure job_templates create --name "lab-template" --project "lab-project" --playbook "playbooks/build-env.yml" --job_type "run" --inventory "lab-inventory" --ask_variables_on_launch True

# associate credentials to lab template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password="${ansible_awx_password}" --conf.insecure job_template associate --credential "lab-linux" --name "lab-template"

# setup domain
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password="${ansible_awx_password}" --conf.insecure job_templates launch 'lab-template' --monitor -f human --extra-vars "@~/deployment/ansible/vars_base.yml"