# create layer from the LINUX distribution docker image
FROM --platform=amd64 debian:buster-slim

RUN mkdir -p /usr/share/man/man1 /usr/share/man/man2

RUN apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y --no-install-recommends \
    apt-utils \
    software-properties-common \
    apt-transport-https \
    build-essential \
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
    openjdk-11-jdk-headless 

RUN apt-get clean autoclean

# set working directory
WORKDIR /

RUN wget "https://github.com/CogStack/CogStack-Pipeline/archive/dev.zip" -O "./CogStack-Pipeline-dev.zip"
RUN unzip -o "./CogStack-Pipeline-dev.zip"
RUN mv "./CogStack-Pipeline-dev" "./cogstack-repo-build"

WORKDIR /cogstack-repo-build

RUN ./gradlew --version
RUN ./gradlew bootJar --no-daemon

# Make new directory for cogstack-pipeline binaries
RUN mkdir /cogstack

# copy artifacts
RUN cp ./build/libs/cogstack-*.jar /cogstack
RUN cp ./scripts/*.sh /cogstack

# copy artifacts
RUN cp ./build/libs/cogstack-*.jar /cogstack
RUN cp ./scripts/*.sh /cogstack

# copy external tools configuration files
RUN cp ./extras/ImageMagick/policy.xml /etc/ImageMagick-6/policy.xml

# install GATE NLP & set environment variable
# RUN mkdir /gate
# 
# WORKDIR /gate 
# 
# RUN wget https://github.com/GateNLP/gate-core/releases/download/v8.6.1/gate-developer-8.6.1-distro.zip
# 
# RUN unzip gate-developer-8.6.1-distro.zip
# RUN mv gate-developer-8.6.1-distro/* ./ 
# RUN rm -rf gate-developer-8.6.1-distro
# 
# ENV GATE_HOME=/gate/

# GATE directories structure:
# - core components: /gate/home/
# - custom user apps: /gate/app/

WORKDIR /gate/

# for the moment use the older GATE bundle containing all plugins and core components 
# TODO: update to GATE 8.5+
RUN curl -L 'https://downloads.sourceforge.net/project/gate/gate/8.4.1/gate-8.4.1-build5753-BIN.zip?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fgate%2Ffiles%2Fgate%2F8.4.1%2Fgate-8.4.1-build5753-BIN.zip' > gate-8.4.1-build5753-BIN.zip && \
	unzip gate-8.4.1-build5753-BIN.zip && \
	mv gate-8.4.1-build5753-BIN home && \
	rm gate-8.4.1-build5753-BIN.zip
    
ENV GATE_HOME=/gate/home

# switch to CogStack main directory
WORKDIR /cogstack

# Remove cogstack-pipeline build dir
RUN rm -rf /cogstack-repo-build

# entry point
CMD /bin/bash