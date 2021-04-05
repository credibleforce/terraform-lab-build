#!/bin/bash

# export SPLUNK_PASSWORD="${splunk_password}"

# rm -rf splunk-deployment
# mkdir splunk-deployment
# cd splunk-deployment
# git clone --recurse-submodules --single-branch --branch 'develop' https://github.com/mobia-security-services/splunk-engagement-ansible.git
# cd splunk-engagement-ansible/ansible
# ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-standalone.yml --extra-vars @~/deployment/ansible/vars_base.yml
# ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/push-standalone-apps.yml --extra-vars @~/deployment/ansible/vars_base.yml
# #ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-distributed.yml --extra-vars @~/deployment/ansible/vars_base.yml
# #ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-indexcluster.yml --extra-vars @~/deployment/ansible/vars_base.yml
# #ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-searchcluster-indexcluster.yml --extra-vars @~/deployment/ansible/vars_base.yml

# sync splunk repo
sudo mkdir /opt/repo
sudo git clone --branch develop --recursive https://github.com/mobia-security-services/splunk-engagement-ansible /opt/repo/splunk-engagement-ansible

# sym link doesn't work (needs further test) just copy ansible directory - ideally structure of repo include ansible.cfg at the root for awx
sudo mkdir -p /opt/awx/projects \
    && sudo cp -pr /opt/repo/splunk-engagement-ansible/ansible /opt/awx/projects/splunk \

# create a splunk project
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password="${ansible_awx_password}" --conf.insecure project create --name "splunk-project" --organization "lab" --scm_type "" --local_path "splunk"

# create splunk job template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password="${ansible_awx_password}" --conf.insecure job_templates create --name "splunk-template" --project "splunk-project" --playbook "playbooks/install-standalone.yml" --job_type "run" --inventory "lab-inventory"

# associate credentials to splunk template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password="${ansible_awx_password}" --conf.insecure job_template associate --credential "lab-linux" --name "splunk-template"

# setup splunk
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password="${ansible_awx_password}" --conf.insecure job_templates launch 'splunk-template' --monitor -f human --extra-vars "@~/deployment/ansible/vars_base.yml"