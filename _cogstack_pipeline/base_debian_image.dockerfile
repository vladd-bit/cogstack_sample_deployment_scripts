FROM scratch

# clear
ARG TAG=base_image_debian
ARG CODE_VERSION=latest
LABEL maintainer="TEAM" \
      version=1.0 \
      TAG=base_image_debian

# create layer from the LINUX distribution docker image
FROM --platform=amd64 debian:buster-slim

RUN mkdir -p /usr/share/man/man1 /usr/share/man/man2

RUN apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y --no-install-recommends \
    apt-utils \
    software-properties-common \
    build-essential \
    apt-transport-https \
    tesseract-ocr \
    ca-certificates \
    gradle \
    imagemagick \
    git \
    zip \
    unzip \
    wget \  
    gcc \
    curl \
    cmake \
    make \
    openjdk-11-jdk-headless \
    python3.7 \
    python3.7-dev \
    python3-pip

# add the DVC repository for the data version control standalone part of the pipeline (optional)
RUN wget \
       https://dvc.org/deb/dvc.list \
       -O /etc/apt/sources.list.d/dvc.list \
       && apt update && apt install -y dvc

RUN apt-get clean autoclean

# set working directory
WORKDIR /

# entry command
CMD "/bin/sh"