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
    && sudo cp -pr /opt/repo/splunk-engagement-ansible/ansible /opt/awx/projects/splunk \

# create atomic redteam
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure project create --name "redcanary-project" --organization "lab" --scm_type "" --local_path "redcanary"

# create atomic redteam template
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_templates create --name "redcanary-template" --project "redcanary-project" --playbook "playbook.yml" --job_type "run" --inventory "lab-inventory" --ask_variables_on_launch True

# associate credentials with atomic redteam template
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_template associate --credential "lab-windows-domain" --name "redcanary-template"

# create a splunk project
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure project create --name "splunk-project" --organization "lab" --scm_type "" --local_path "splunk"

# create splunk job template
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_templates create --name "splunk-template" --project "splunk-project" --playbook "playbooks/install-standalone.yml" --job_type "run" --inventory "lab-inventory" --ask_variables_on_launch True
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_templates create --name "splunk-apps-template" --project "splunk-project" --playbook "playbooks/push-standalone-apps.yml" --job_type "run" --inventory "lab-inventory" --ask_variables_on_launch True
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_templates create --name "splunk-mitre-apps-template" --project "splunk-project" --playbook "playbooks/push-standalone-mitre-apps.yml" --job_type "run" --inventory "lab-inventory" --ask_variables_on_launch True

# associate credentials to splunk template
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_template associate --credential "lab-linux" --name "splunk-template"
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_template associate --credential "lab-linux" --name "splunk-apps-template"
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_template associate --credential "lab-linux" --name "splunk-mitre-apps-template"

# setup splunk
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_templates launch 'splunk-template' --monitor -f human --extra_vars "@~/deployment/ansible/lab_settings.yml"
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_templates launch 'splunk-apps-template' --monitor -f human --extra_vars "@~/deployment/ansible/lab_settings.yml"
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_templates launch 'splunk-mitre-apps-template' --monitor -f human --extra_vars "@~/deployment/ansible/lab_settings.yml"
