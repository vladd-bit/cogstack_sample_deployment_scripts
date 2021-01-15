#!/usr/bin/env bash

echo "This script must be run with root privileges."

os_distribution="$(exec ./detect_os.sh)"
echo "Found distribution: $os_distribution "

if [ "$os_distribution" == "debian" ] || [ "$os_distribution" == "ubuntu" ];
then
    sudo apt-get update -y && sudo apt-get upgrade -y

    sudo apt-get install -y libreoffice 
    sudo apt-get install -y wget curl git python3 python3-pip openssl-devel zip unzip tar nano gcc gcc-c++ make python3-dev build-essential
    
    # create docker group and add the root user to it, as root will be used to run the docker process
    sudo groupadd docker
    sudo usermod -aG docker root
    sudo usermod -aG docker $USER

    # start the service
    sudo systemctl enable docker.service
    sudo systemctl start docker

    sudo apt-get -y autoremove

elif  [ "$os_distribution" == "redhat" ] || [ "$os_distribution" == "red hat" ] || [ "$os_distribution" == "centos" ]; 
then
    yum -y update && yum -y upgrade

    sudo yum install libreoffice-base
  
    sudo yum remove -y docker \
                    docker-client \
                    docker-client-latest \
                    docker-common \
                    docker-latest \
                    docker-latest-logrotate \
                    docker-logrotate \
                    docker-engine

    sudo yum remove -y buildah podman

    # install necessary prerequisites
    sudo yum install -y yum-utils wget curl git device-mapper-persistent-data lvm2 python3 python3-pip libffi-devel openssl-devel zip unzip tar nano gcc gcc-c++ make python3-devel libevent-devel
    
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum-config-manager --enable docker-ce-stable
    sudo yum-config-manager --enable docker-ce-stable-source
    sudo yum install -y docker-ce docker-ce-cli containerd.io

    sudo pip3 install docker-compose
    sudo pip3 install html2text

    # create docker group and add the root user to it, as root will be used to run the docker process
    sudo groupadd docker
    sudo usermod -aG docker root
    sudo usermod -aG docker $USER

    # start the service
    sudo systemctl enable docker.service
    sudo systemctl start docker

    sudo yum -y autoremove
else
    exit 1
fi;

echo "Finished installing docker and utils.."