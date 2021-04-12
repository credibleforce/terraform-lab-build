#!/bin/bash

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

# install python docker
sudo pip3 install docker docker-compose

# enable docker service at startup
sudo systemctl enable docker

# start docker
sudo systemctl start docker

# clone aws repository
git clone --branch 15.0.1 --recursive https://github.com/ansible/awx.git

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
docker_compose_dir="/opt/awx/awxcompose"
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
sudo ansible-playbook -i lab-inventory install.yml -e @vars.yml

# sleep
sleep 60

# exec migration task and restart the containers to ensure upgrade/migration completes before first run
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
sudo cp -pr /opt/repo/splunk-engagement-ansible/ansible /opt/awx/projects/splunk
sudo cp -pr /opt/repo/splunk-lab/ansible /opt/awx/projects/lab

# create an inventory place holder
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure inventory create --name "lab-inventory" --organization "Default"

# copy inventory to awx_task container
sudo docker cp "${HOME}/lab.yml" "awx_task:lab.yml"

# import inventory using awx-manage
sudo docker exec -it awx_task /bin/bash -c "awx-manage inventory_import --source=lab.yml --inventory-name=lab-inventory --overwrite --overwrite-vars"

# create a lab project
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure project create --name "lab-project" --organization "Default" --scm_type "" --local_path "lab"

# create a splunk project
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure project create --name "splunk-project" --organization "Default" --scm_type "" --local_path "splunk"

# add ssh key credentials to awx 
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure credential create --name="lab-linux" --organization="Default" --credential_type="Machine" --inputs="{\"username\":\"vagrant\",\"ssh_key_data\":\"@~/.ssh/id_rsa\"}"

# add windows non-domain credentials to awx
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure credential create --name="lab-windows-local" --organization="Default" --credential_type="Machine" --inputs="{\"username\":\"vagrant\",\"password\":\"changme\"}"

# add windows domain credentials to awx
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure credential create --name="lab-windows-domain" --organization="Default" --credential_type="Machine" --inputs="{\"username\":\"administrator\",\"password\":\"changeme\"}"

# create lab job template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_template create --name "lab-template" --project "lab-project" --playbook "playbooks/build-env.yml" --job_type "run" --inventory "lab-inventory" --become_enabled True

# associate credentials to lab template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_template associate --credential "lab-linux" --name "lab-template"

# create splunk job template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_template create --name "splunk-template" --project "splunk-project" --playbook "playbooks/install-standalone.yml" --job_type "run" --inventory "lab-inventory" --become_enabled True

# associate credentials to splunk template
awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_template associate --credential "lab-linux" --name "splunk-template"

# # run the job lab template
# awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_templates launch 'lab-template' --monitor -f human

# # run the job splunk template
# awx --conf.host=http://localhost:80 --conf.username=admin --conf.password=password --conf.insecure job_templates launch 'splunk-template' --monitor -f human