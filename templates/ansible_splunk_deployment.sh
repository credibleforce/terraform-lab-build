#!/bin/bash

export SPLUNK_PASSWORD="${splunk_password}"

rm -rf splunk-deployment
mkdir splunk-deployment
source ./ansible/hacking/env-setup
cd splunk-deployment
git clone --single-branch --branch 'develop' https://github.com/ps-sec-analytics/splunk-engagement-ansible.git
cd splunk-engagement-ansible
git submodule update --init --recursive
cd ansible
#ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-standalone.yml --extra-vars @~/deployment/ansible/vars_base.yml
#ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-distributed.yml --extra-vars @~/deployment/ansible/vars_base.yml
ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-indexcluster.yml --extra-vars @~/deployment/ansible/vars_base.yml
#ansible-playbook -vv -i ~/deployment/ansible/inventory.yml playbooks/install-searchcluster-indexcluster.yml --extra-vars @~/deployment/ansible/vars_base.yml