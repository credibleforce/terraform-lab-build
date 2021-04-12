#!/bin/bash

export PATH=$PATH:/usr/local/bin

# sync splunk repo
sudo mkdir /opt/repo 2> /dev/null
sudo rm -rf /opt/repo/splunk-engagement-ansible 2> /dev/null
sudo git clone --branch develop --recursive https://github.com/mobia-security-services/splunk-engagement-ansible /opt/repo/splunk-engagement-ansible
sudo git clone --branch develop --recursive https://github.com/mobia-security-services/ansible-invoke-atomic-redteam /opt/awx/projects/redcanary

# sym link doesn't work (needs further test) just copy ansible directory - ideally structure of repo include ansible.cfg at the root for awx
sudo mkdir -p /opt/awx/projects \
    && sudo rm -rf /opt/awx/projects/splunk \
    && sudo cp -pr /opt/repo/splunk-engagement-ansible/ansible /opt/awx/projects/splunk

# base configuration for awx
cd ~/deployment/ansible/
ansible-playbook -vv -i ~/deployment/ansible/inventory.yml ~/deployment/ansible/playbooks/awx-splunk-deploy.yml --vault-password-file ~/deployment/ansible/.vault_passwd.txt  --extra-vars "@~/deployment/ansible/lab_settings.yml"