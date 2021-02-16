#!/bin/bash

# change working directory
cd deployment/ansible

# setup ansible deployment user locally and on all linux targets
export ANSIBLE_USER="${ansible_deployment_user}" ANSIBLE_GROUP="${ansible_deployment_group}" CURRENT_USER="$(whoami)"

# all ssh keys to known hosts
ansible-playbook -vv -i inventory.yml playbooks/ssh-keyscan.yml --limit "local" --extra-vars "@vars_base.yml"
ansible-playbook -vv -i inventory.yml playbooks/ssh-keyscan.yml --limit "linux" --extra-vars "@vars_base.yml"

# # push deployment user
# ansible-playbook -vv -i inventory.yml playbooks/ansible-user.yml --limit "local" --extra-vars "@vars_base.yml"
# ansible-playbook -vv -i inventory.yml playbooks/ansible-user.yml --limit "linux" --extra-vars "@vars_base.yml"

# # stage ansible for deployment user
# sudo cp -pr /home/$CURRENT_USER/ansible /home/${ansible_deployment_user}/
# sudo cp -pr /home/$CURRENT_USER/deployment /home/${ansible_deployment_user}/
# sudo chown -R ${ansible_deployment_user}:${ansible_deployment_group} /home/${ansible_deployment_user}

# # switch context from centos to ${ansible_deployment_user} and setup known hosts
# sudo su - ${ansible_deployment_user} -c 'source ./ansible/hacking/env-setup && cd ./deployment/ansible && ansible-playbook -vv -i inventory.yml ./playbooks/ssh-keyscan.yml --limit "local" --extra-vars "@vars_deployer.yml"'
# sudo su - ${ansible_deployment_user} -c 'source ./ansible/hacking/env-setup && cd ./deployment/ansible && ansible-playbook -vv -i inventory.yml ./playbooks/ssh-keyscan.yml --limit "linux" --extra-vars "@vars_deployer.yml"'