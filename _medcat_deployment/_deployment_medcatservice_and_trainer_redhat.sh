#!/usr/bin/bash

echo "This script must be run with root privileges."

yum -y update && yum -y upgrade

subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms
subscription-manager repos --enable=rhel-8-server-optional-rpms
subscription-manager repos --enable=rhel-7-server-extras-rpms
subscription-manager repos --enable rhel-7-server-optional-rpms

yum install -y yum-utils wget curl device-mapper-persistent-data lvm2 libffi-devel openssl-devel zip unzip tar nano gcc gcc-c++ make python3-devel libevent-devel

yum install -y python3 python3-pip 

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-stable
yum-config-manager --enable docker-ce-stable-source

yum install -y docker-ce docker-ce-cli containerd.io

usermod -aG docker $USER

systemctl enable docker.service
systemctl start docker

pip3 --user install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.2.4/en_core_sci_md-0.2.4.tar.gz
python3 -m spacy download en_core_web_sm
pip3 --user install docker-compose gunicorn flask werkzeug wheel uwsgi setuptools cython cpython

mkdir /root/deployment
cd /root/deployment

rm -rf ./MedCATservice-master 
rm -rf ./MedCATtrainer-master 

wget https://github.com/CogStack/MedCATtrainer/archive/master.zip
mv ./master.zip ./medcat-trainer-master.zip
unzip -o ./medcat-trainer-master.zip 

wget https://github.com/CogStack/MedCATservice/archive/master.zip
mv ./master.zip ./medcat-service-master.zip
unzip -o ./medcat-service-master.zip 

pip3 install -r ./MedCATservice-master/medcat_service/requirements.txt

rm -rf /etc/MedCATservice
rm -rf /etc/MedCATtrainer

mv ./MedCATservice-master /etc/MedCATservice
mv ./MedCATtrainer-master /etc/MedCATtrainer

yes | cp ./systemd_medcat.service /etc/systemd/system/systemd_medcat.service

# Change permissions to root user or whatever user will be running the service
chown -R root:root /etc/MedCATservice
chown -R root:root /etc/MedCATtrainer

chmod -R 755 /etc/MedCATservice
chmod -R 755 /etc/MedCATtrainer

chown root:root /etc/systemd/system/systemd_medcat.service
chmod 755 /etc/systemd/system/systemd_medcat.service 

# Allow execution of script
chmod +x /etc/MedCATservice/start-service-prod.sh

# Validate and start service
systemd-analyze verify systemd_medcat.service
systemctl disable systemd_medcat.service
systemctl stop systemd_medcat.service
systemctl enable systemd_medcat.service
systemctl start systemd_medcat.service


