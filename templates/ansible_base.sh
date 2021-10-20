#!/bin/bash

# ensure /usr/local/bin is in global path for /bin/sh (awx requirement)
sudo /bin/bash -c 'cat >>/etc/profile.d/add_local_path.sh<<EOF
PATH=$PATH:/usr/local/bin
EOF'
sudo chmod +x /etc/profile.d/add_local_path.sh

export PATH=$PATH:/usr/local/bin

# install ansible and git
sudo yum install -y \
    epel-release \
    git \
    patch \
    python3 \
    python3-pip \
    jq
sudo alternatives --set python /usr/bin/python3

# Install local Ansible.
sudo yum install -y ansible gcc python3-pip python3-kerberos python3-devel krb5-devel krb5-libs krb5-workstation
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install \
    pywinrm \
    requests \
    virtualenv
sudo python3 -m pip install \
    pywinrm[kerberos] \
    pywinrm[credssp]

# Vault lab settings - extra-vars bug in awx prevents vaulted creds
#${HOME}/deployment/ansible/convert_vault.py --input-file ${HOME}/deployment/ansible/lab_settings.tmp --vault-password-file ${HOME}/deployment/ansible/.vault_passwd.txt > ${HOME}/deployment/ansible/lab_settings.yml
#${HOME}/deployment/ansible/convert_vault.py --input-file ${HOME}/deployment/ansible/vars.tmp --vault-password-file ${HOME}/deployment/ansible/.vault_passwd.txt > ${HOME}/deployment/ansible/vars.yml
#rm -f ${HOME}/deployment/ansible/*.tmp

# Stage awx certs
cd ${HOME}/deployment/ansible
ansible-playbook -vv -i ${HOME}/deployment/ansible/inventory.yml --vault-password-file ${HOME}/deployment/ansible/.vault_passwd.txt  ${HOME}/deployment/ansible/playbooks/awx-self-signed-ssl.yml --extra-vars "@${HOME}/deployment/ansible/lab_settings.yml"

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

# enable docker service at startup
sudo systemctl enable docker

# start docker
sudo systemctl start docker

# clone aws repository
rm -rf ./awx
git clone --branch 16.0.0 --recursive https://github.com/ansible/awx.git

cd ${HOME}/deployment/ansible/awx/installer

cat >lab-inventory<<EOF
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python3"

[all:vars]
dockerhub_base=ansible
awx_task_hostname=awx
awx_web_hostname=awxweb
postgres_data_dir="/opt/awx/pgdocker"
host_port=80
host_port_ssl=443
ssl_certificate=/opt/awx/certs/awx.pem
ssl_certificate_key=/opt/awx/certs/awx.key
docker_compose_dir="${HOME}/.awx/awxcompose"
pg_username=awx
pg_database=awx
pg_port=5432
admin_user=admin
create_preload_data=False
project_data_dir=/opt/awx/projects
EOF

# install awx
sudo ansible-playbook -vvv -i ${HOME}/deployment/ansible/awx/installer/lab-inventory ${HOME}/deployment/ansible/awx/installer/install.yml --vault-password-file ${HOME}/deployment/ansible/.vault_passwd.txt -e "@${HOME}/deployment/ansible/vars.yml"

# sleep
sleep 60

# exec migration task and restart the containers to ensure upgrade/migration completes before first run
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin docker exec -it awx_web /bin/bash -c \"awx-manage migrate --noinput\""
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin docker stop awx_task awx_web"
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin docker start awx_task awx_web"

# sleep
sleep 120

# add hashi_vault dependancies
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin virtualenv /opt/awx/envs/proservlab-cloud"
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin python3 -m venv /opt/awx/envs/proservlab-cloud"
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin /opt/awx/envs/proservlab-cloud/bin/pip3 install --upgrade pip"
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin /opt/awx/envs/proservlab-cloud/bin/pip3 install psutil"
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin /opt/awx/envs/proservlab-cloud/bin/pip3 install -U pywinrm"
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin /opt/awx/envs/proservlab-cloud/bin/pip3 install -U hvac"
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin /opt/awx/envs/proservlab-cloud/bin/pip3 install -U hvac[parser]"
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin docker cp /opt/awx/envs/proservlab-cloud awx_task:/var/lib/awx/venv/"
sudo /bin/bash -c "PATH=$PATH:/usr/local/bin docker cp /opt/awx/envs/proservlab-cloud awx_web:/var/lib/awx/venv/"

# awxcli (optional)
sudo /bin/bash -l -c "PATH=$PATH:/usr/local/bin python3 -m pip install awxkit"

# base configuration for awx projects
cd ${HOME}/deployment/ansible/
ansible-playbook -vv -i ${HOME}/deployment/ansible/inventory.yml ${HOME}/deployment/ansible/playbooks/awx-setup.yml --vault-password-file ${HOME}/deployment/ansible/.vault_passwd.txt --extra-vars "@${HOME}/deployment/ansible/lab_settings.yml"
#rm -f ${HOME}/deployment/ansible/.vault_passwd.txt