#! /bin/sh
#
# vboxshare.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.white@cern.ch>
#
# Distributed under terms of the  license.
#

if [[ ! -d "/media/cdrom" ]]
then
    executor 'sudo mkdir /media/cdrom' 
    executor 'sudo mount /dev/cdrom /media/cdrom'
fi
if [[ -f "/media/cdrom/VBoxLinuxAdditions.run" ]]
then
    executor 'sudo /media/cdrom/VBoxLinuxAdditions.run'
else
    logger "${error} VBoxLinuxAdditions.run not found!"
fi


