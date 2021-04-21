#!/usr/bin/env bash

pip3 install --upgrade pip
pip3 install html2text jsoncsv detect wheel elasticsearch seaborn matplotlib tqdm && pip3 install medcat && pip install ipywidgets jupyter jupyterlab && pip install jupyterhub-nativeauthenticator jupyterhub-firstuseauthenticator
pip3 install jupyter_contrib_nbextensions

jupyter contrib nbextension install --sys-prefix

# install R 
apt-get update && apt-get upgrade -y && \
    apt-get install -y –no-install-recommends \
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

# Fix for devtools https://github.com/conda-forge/r-devtools-feedstock/issues/4
# ln -s /bin/tar /bin/gtar
#wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
