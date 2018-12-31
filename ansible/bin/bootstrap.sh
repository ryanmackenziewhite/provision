#! /bin/sh
#
# bootstrap.sh
# Copyright (C) 2018 Ryan Mackenzie White <ryan.white4@canada.ca>
#
# Distributed under terms of the  license.
#

echo "Installing ansible for provisioning for \"${USER}\" "

sudo yum -y install ansible
sudo yum -y install make

if [[ -f "/etc/os-release" ]]
then
    . /etc/os-release
    __OS=$NAME
    if [[ ${__OS} == "Fedora" ]]
    then
        sudo yum -y install python-unversioned-command
    fi
fi
