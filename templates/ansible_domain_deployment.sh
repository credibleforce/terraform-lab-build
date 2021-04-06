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

# create a lab project
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure project create --name "lab-project" --organization "lab" --scm_type "" --local_path "lab"

# create lab job template
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_templates create --name "lab-template" --project "lab-project" --playbook "playbooks/build-env.yml" --job_type "run" --inventory "lab-inventory" --ask_variables_on_launch True

# associate credentials to lab template
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_template associate --credential "lab-linux" --name "lab-template"

# setup domain
awx --conf.host "http://localhost:80" --conf.username admin --conf.password "${ansible_awx_password}" --conf.insecure job_templates launch 'lab-template' --monitor -f human --extra_vars "@~/deployment/ansible/lab_settings.yml"