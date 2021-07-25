#!/bin/bash -v
echo "userdata-start"
sudo su -
yum update -y
yum groupinstall "Development Tools" -y
yum install -y yum-utils device-mapper-persistent-data lvm2 wget python3
pip3 install boto3 --user
yum remove docker docker-common docker-selinux docker-engine-selinux docker-engine docker-ce -y
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce -y
systemctl enable docker.service
systemctl start docker
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo "End of UserData"
