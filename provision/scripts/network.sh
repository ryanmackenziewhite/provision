#! /bin/bash
#
# network.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.whitei4@canada.ca>
#
#

THISHOST=$(hostname)
logger "Hostname is: ${THISHOST}"
echo -ne "\n${question} Set the node name: "
#read nodename

logger "Nodename is: ${nodename}"

echo -ne "\n${question} Set the IP address for ${nodename}: "
#read ipaddr
logger "IP address for ${nodename} is ${ipaddr}"

logger "${info} Update hosts information for ${nodename} on host ${THISHOST}"
logger "${info} ${ipaddr}  ${nodename}  ${THISHOST}" 

if [[ $__DEBUG == false ]]
then
    if [[ ${__OS} == "CentOS Linux" ]]
    then
        logger "${info} CentOS Linux network"
        sudo perl -i -pe "s/BOOTPROTO=dhcp/BOOTPROTO=static/g" /etc/sysconfig/network-scripts/ifcfg-enp0s8
        sudo perl -i -pe "s/ONBOOT=no/ONBOOT=yes/g" /etc/sysconfig/network-scripts/ifcfg-enp0s8
        echo -e "IPADDR=${ipaddr}" | sudo tee -a "/etc/sysconfig/network-scripts/ifcfg-enp0s8"
        echo -e "NETMASK=${networkcfg[3]}" | sudo tee -a "/etc/sysconfig/network-scripts/ifcfg-enp0s8"
        echo -e "NETWORKING=yes" | sudo tee -a "/etc/sysconfig/network"
        echo -e "HOSTNAME=${THISHOST}" | sudo tee -a "/etc/sysconfig/network"
        echo -e "GATEWAY=${networkcfg[2]}" | sudo tee -a "/etc/sysconfig/network"
	
	echo -e "${ipaddr}  ${nodename}  ${THISHOST}" | sudo tee -a "/etc/hosts"
	executor "sudo /etc/init.d/network restart"
    elif [[ ${__OS} == "Ubuntu" ]]
    then
        echo -e " " | sudo tee -a "/etc/network/interfaces"
        echo -e "auto enp0s8" | sudo tee -a "/etc/network/interfaces"
        echo -e "iface enp0s8 inet static" | sudo tee -a "/etc/network/interfaces"
        echo -e "address ${ipaddr}" | sudo tee -a "/etc/network/interfaces"
        echo -e "network ${networkcfg[2]}" | sudo tee -a "/etc/network/interfaces"  
        echo -e "netmask ${networkcfg[3]}" | sudo tee -a "/etc/network/interfaces"
	echo -e "${ipaddr}  ${nodename}  ${THISHOST}" | sudo tee -a "/etc/hosts"
	executor "sudo /etc/init.d/networking restart"
    else 
        logger "${error} Cannot configure network"
    fi
else
    logger "${DEBUG} Configure the node: ${networkcfg[0]} ${networkcfg[1]}"
fi



