# install ansible and git
sudo yum install -y epel-release
sudo yum install -y git
sudo yum install -y patch
sudo yum install -y python-pip
sudo pip install --upgrade pip
sudo pip install pywinrm --ignore-installed requests

# pull ansible from github
rm -rf ansible
git clone --single-branch --branch 'stable-2.9' https://github.com/ansible/ansible.git
pip install -r ./ansible/requirements.txt

# use local git repo for ansible
source ./ansible/hacking/env-setup

# change working directory
cd deployment/ansible

# all ssh keys to known hosts
ansible-playbook -vv -i inventory.yml playbooks/ssh-keyscan.yml --limit "local" --extra-vars "@vars_base.yml"
ansible-playbook -vv -i inventory.yml playbooks/ssh-keyscan.yml --limit "linux" --extra-vars "@vars_base.yml"