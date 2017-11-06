#! /bin/bash
#
# users.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.white4@canada.ca>
#
# Distributed under terms of the  license.
#

logger "${info} Setup users"

for user in ${users[@]}
do
    logger "${info} Create user account: ${user}"
    exists=$(grep -c "^${user}:" /etc/passwd)
    if [[ ${exists} == 0 ]]
    then
        logger "${info} Create ${user}"
        if [[ ${user} == "hadoop" ]]
        then
            executor "sudo useradd -m -G vboxsf ${user}"
        else
	    executor "sudo useradd -m -G hadoop,vboxsf ${user}"
        fi
    else
        logger "${info} Modify groups for ${user}"
        executor "sudo usermod -aG vboxsf ${user}"
        executor "sudo usermod -aG hadoop ${user}"
    fi
done


