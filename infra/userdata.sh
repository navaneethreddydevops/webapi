#!/bin/bash -v
echo "userdata-start"
sudo su -
yum update -y
yum install -y yum-utils device-mapper-persistent-data lvm2
yum install docker -y
echo "userdata-end"
