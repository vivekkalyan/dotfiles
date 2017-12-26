#!usr/bin/env bash

sudo add-apt-repository ppa:aacebedo/fasd

sudo apt update
sudo apt upgrade

sudo apt install -y  \
    coreutils \
    p7zip \
    python3 \
    python-pip \
    git \
    zsh

sudo sh -c 'echo /bin/zsh >> /etc/shells' && \
chsh -s /bin/zsh
