#! /bin/bash
#
# keys.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.white4@canada.ca>
#
# Distributed under terms of the  license.
#

echo -e "${networkcfg[1]}  ${networkcfg[0]}" | sudo tee -a $__SHARE_FILEPATH/$__HOSTS_FILENAME  
echo -e "${networkcfg[0]}" | sudo tee -a $__SHARE_FILEPATH/slaves   

for user in ${users[@]}
do
    logger "${info} Create keys for user ${user}" 
    if [[ $__DEBUG == false ]]
    then
        sudo -u ${user} ssh-keygen -t rsa -P '' -f /home/${user}/.ssh/id_rsa
        sudo -u ${user} cat /home/${user}/.ssh/id_rsa.pub | sudo -u ${user} tee -a /home/${user}/.ssh/authorized_keys
        sudo -u ${user} chmod 0600 /home/${user}/.ssh/authorized_keys
        sudo -u ${user} cat /home/${user}/.ssh/authorized_keys | tee -a $__SHARE_FILEPATH/$__KEYS_FILENAME
    fi
done


