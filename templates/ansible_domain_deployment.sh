#!/bin/bash

export PATH=$PATH:/usr/local/bin

# sync lab repo
sudo mkdir /opt/repo 2> /dev/null
sudo rm -rf /opt/repo/splunk-lab 2> /dev/null
sudo git clone --branch develop --recursive https://github.com/mobia-security-services/splunk-lab /opt/repo/splunk-lab

# sym link doesn't work (needs further test) just copy ansible directory - ideally structure of repo include ansible.cfg at the root for awx
sudo mkdir -p /opt/awx/projects \
    && sudo rm -rf /opt/awx/projects/lab \
    && sudo cp -pr /opt/repo/splunk-lab/ansible /opt/awx/projects/lab

# base configuration for awx
cd ~/deployment/ansible/
ansible-playbook -vv -i ~/deployment/ansible/inventory.yml ~/deployment/ansible/playbooks/awx-domain-deploy.yml --vault-password-file ~/deployment/ansible/.vault_passwd.txt --extra-vars "@~/deployment/ansible/lab_settings.yml"

# stop and start awx container to load updated certs
sudo docker stop awx_web
sudo docker start awx_web