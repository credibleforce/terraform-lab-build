#!/bin/bash

# install ansible and git
sudo yum install -y \
    epel-release \
    git \
    patch \
    python3 \
    python3-pip
#sudo alternatives --set python /usr/bin/python3

# Install local Ansible.
sudo yum install -y ansible gcc python3-pip python3-devel krb5-devel krb5-libs krb5-workstation
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install \
    pywinrm \
    requests \
    pywinrm[kerberos] \
    pywinrm[credssp]

# Install awx
# remove existing docker configuration
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine 

# install yum-utils
sudo yum install -y yum-utils

# add docker repo
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


# install docker
sudo yum install -y docker-ce docker-ce-cli containerd.io

# install python docker-compose and link
sudo python3 -m pip install docker docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# enable docker service at startup
sudo systemctl enable docker

# start docker
sudo systemctl start docker

# clone aws repository
rm -rf ./awx
git clone --branch 16.0.0 --recursive https://github.com/ansible/awx.git

cd awx/installer

cat >lab-inventory<<EOF
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python3"

[all:vars]
dockerhub_base=ansible
awx_task_hostname=awx
awx_web_hostname=awxweb
postgres_data_dir="/opt/awx/pgdocker"
host_port=80
host_port_ssl=443
docker_compose_dir="~/.awx/awxcompose"
pg_username=awx
pg_database=awx
pg_port=5432
admin_user=admin
create_preload_data=False
project_data_dir=/opt/awx/projects
EOF

cat >vars.yml<<EOF
admin_password: 'password'
pg_password: 'awxpass'
secret_key: 'awxsecret'
EOF

# install awx
sudo ansible-playbook -vvv -i lab-inventory install.yml -e @vars.yml

# sleep
sleep 60

# # exec migration task and restart the containers to ensure upgrade/migration completes before first run
sudo docker exec -it awx_web /bin/bash -c "awx-manage migrate --noinput"
sudo docker stop awx_task awx_web
sudo docker start awx_task awx_web

# sleep
sleep 30

# awxcli (optional)
sudo pip3 install awxkit

# sync splunk repo
sudo mkdir /opt/repo
sudo git clone --branch develop --recursive https://github.com/mobia-security-services/splunk-engagement-ansible /opt/repo/splunk-engagement-ansible
sudo git clone --branch develop --recursive https://github.com/mobia-security-services/splunk-lab /opt/repo/splunk-lab

# sym link doesn't work (needs further test) just copy ansible directory - ideally structure of repo include ansible.cfg at the root for awx
sudo mkdir -p /opt/awx/projects
sudo cp -pr /opt/repo/splunk-engagement-ansible/ansible /opt/awx/projects/splunk
sudo cp -pr /opt/repo/splunk-lab/ansible /opt/awx/projects/lab

# create an organization
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure organization create --name "Default"

# create an inventory place holder
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure inventory create --name "lab-inventory" --organization "Default"

# copy inventory to awx_task container
sudo docker cp "$HOME/deployment/ansible/inventory.yml" "awx_task:lab.yml"

# import inventory using awx-manage
sudo docker exec -it awx_task /bin/bash -c "awx-manage inventory_import --source=lab.yml --inventory-name=lab-inventory --overwrite --overwrite-vars"

# create a lab project
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure project create --name "lab-project" --organization "Default" --scm_type "" --local_path "lab"

# create a splunk project
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure project create --name "splunk-project" --organization "Default" --scm_type "" --local_path "splunk"

# add ssh key credentials to awx 
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure credential create --name="lab-linux" --organization="Default" --credential_type="Machine" --inputs="{\"username\":\"vagrant\",\"ssh_key_data\":\"@~/.ssh/id_rsa\"}"

# add windows non-domain credentials to awx
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure credential create --name="lab-windows-local" --organization="Default" --credential_type="Machine" --inputs="{\"username\":\"administrator\",\"password\":\"myTempPassword123\"}"

# add windows domain credentials to awx
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure credential create --name="lab-windows-domain" --organization="Default" --credential_type="Machine" --inputs="{\"username\":\"administrator@lab.lan\",\"password\":\"myTempPassword123\"}"

# create lab job template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_template create --name "lab-template" --project "lab-project" --playbook "playbooks/build-env.yml" --job_type "run" --inventory "lab-inventory" --ask_variables_on_launch True

# associate credentials to lab template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_template associate --credential "lab-linux" --name "lab-template"

# create splunk job template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_template create --name "splunk-template" --project "splunk-project" --playbook "playbooks/install-standalone.yml" --job_type "run" --inventory "lab-inventory"

# associate credentials to splunk template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_template associate --credential "lab-linux" --name "splunk-template"

# # run the job lab template
# awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_templates launch 'lab-template' --monitor -f human

# # run the job splunk template
# awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_templates launch 'splunk-template' --monitor -f human

# local ssh key sync

# change working directory
cd ~/deployment/ansible

# all ssh keys to known hosts
ansible-playbook -vv -i inventory.yml playbooks/ssh-keyscan.yml --extra-vars "@vars_base.yml"

# setup domain
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_templates launch 'lab-template' --monitor -f human --extra-vars "@vars_base.yml"

# setup splunk
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_templates launch 'splunk-template' --monitor -f human