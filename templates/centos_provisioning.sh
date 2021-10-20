#!/bin/bash
echo '127.0.0.1 ${short_name} ${full_name}' | sudo tee -a /etc/hosts
sudo hostnamectl set-hostname ${full_name}
sudo yum clean all && yum makecache && yum -y update
sudo yum install -y ca-certificates ntp ntpdate ntp-doc && sudo chkconfig ntpd on && sudo ntpdate pool.ntp.org && sudo systemctl enable ntpd.service && sudo systemctl start ntpd.service
hostname
