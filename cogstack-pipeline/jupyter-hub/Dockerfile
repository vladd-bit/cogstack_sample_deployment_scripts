FROM jupyter/datascience-notebook:latest

USER root

ARG HTTP_PROXY=$http_proxy
ARG HTTPS_PROXY=$https_proxy
ARG no_proxy=$no_proxy

# install R
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --allow-unauthenticated --no-install-recommends \
    gnupg-agent \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    fonts-dejavu \
    build-essential \
    python3-dev \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    gcc \
    git \
    ssh \
    jq \
    htop \
    wget \
    curl \
    r-base
