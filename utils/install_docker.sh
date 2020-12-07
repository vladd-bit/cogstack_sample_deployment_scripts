#!/usr/bin/env bash

echo "This script must be run with root privileges."

os_distribution="$(exec ./detect_os.sh)"
echo "Found distribution: $os_distribution "

if [ $os_distribution = "debian" ] || [ $os_distribution = "ubuntu" ]
then
    echo "No instructions given for distribution: $os_distribution" 
elif  [ $os_distribution = "redhat" ] || [ $os_distribution = "red hat" ] || [ $os_distribution = "centos" ] 
then
    yum -y update && yum -y upgrade
    subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms
    subscription-manager repos --enable=rhel-8-server-optional-rpms

    # install necessary prerequisites
    yum install -y yum-utils wget curl device-mapper-persistent-data lvm2 python3 python3-pip libffi-devel openssl-devel zip unzip tar nano gcc gcc-c++ make python3-devel libevent-devel
    
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum-config-manager --enable docker-ce-stable
    yum-config-manager --enable docker-ce-stable-source
    yum install -y docker-ce docker-ce-cli containerd.io

    pip3 install -y docker-compose

    # create docker group and add the root user to it, as root will be used to run the docker process
    groupadd docker
    usermod -aG docker root
    usermod -aG docker $USER

    # start the service
    systemctl enable docker.service
    systemctl start docker
else
    exit 1
fi;