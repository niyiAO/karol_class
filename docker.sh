#!/bin/bash

#shell script to install docker

sudo apt-get update

sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"

sudo apt-get update
sudo apt-get -y --force-yes install docker-ce
sudo apt-get -y upgrade

sudo groupadd docker
sudo usermod -aG docker $USER
