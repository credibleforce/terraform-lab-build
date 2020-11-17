#!/bin/bash

export SPLUNK_PASSWORD="${splunk_password}"

rm -rf splunk-deployment
mkdir splunk-deployment
source ./ansible/hacking/env-setup
cd splunk-deployment
git clone --recurse-submodules --single-branch --branch 'develop' https://github.com/mobia-security-services/splunk-engagement-ansible.git
cd splunk-engagement-ansible/ansible
ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-standalone.yml --extra-vars @~/deployment/ansible/vars_base.yml
#ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-distributed.yml --extra-vars @~/deployment/ansible/vars_base.yml
#ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-indexcluster.yml --extra-vars @~/deployment/ansible/vars_base.yml
#ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-searchcluster-indexcluster.yml --extra-vars @~/deployment/ansible/vars_base.yml