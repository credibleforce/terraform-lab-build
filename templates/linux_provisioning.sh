#!/bin/bash
echo '127.0.0.1 ${short_name} ${full_name}' | sudo tee -a /etc/hosts
sudo hostnamectl set-hostname ${full_name}