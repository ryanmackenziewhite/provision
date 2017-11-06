#! /bin/bash
#
# provision.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.white4@canada.ca>
#
# Inspired from https://github.com/jream/provision-bash.git

##################################################
# Environment variables
#source bin/variables.sh
export __DEBUG=false
#export __LOGGER_FILEPATH=""
#export __LOGGER_FILENAME=".log"
export __SHARE_FILEPATH="/media/sf_vmshare/"
export __HOSTS_FILENAME="hosts.txt"
export __KEYS_FILENAME="keys.txt"
export __HADOOP_VERSION="hadoop-2.7.4"
export __HADOOP_PATH="/opt/hadoop"
export __MEDIA="dvd"
export __OS="Ubuntu"
export __PKGMGR="apt-get"
export __SETKEYS=false
##################################################

# $ desc        Absolute URL to current working directory.
# $ important   Do NOT overwrite this, it's for including files
# If __APP_BASEPATH is not set, set the path to this folder,
# If one were to us eonly the bin folder and this is at the root
if [[ ! $__APP_BASEPATH ]]; then
    __APP_BASEPATH=$( cd $(dirname $0) ; pwd -P )
fi

##################################################
# Help
# For double brackets explanation, see ch 7.1 in Advanced Bash-Scripting
if [[ $1 == 'help' || $1 == '-h' || $1 == '--help' ]] 
then
    echo "Usage:"
    echo "./provision.sh <nodename> <ipaddress>"
    echo "Options"
    echo "--debug Prints all commands, does not execute"
    echo "--keys Copies keys to slaves"
    echo "Requires running twice, reboot occurs, log back in and rerun"
    exit 1
fi

# Version
if [[ $1 == 'V' || $1 == 'v' || $1 == '--version' ]] 
then
    echo "Version 0.0"
    exit 1
fi
##################################################

# Debug
if [[ $1 == '--debug' ]] 
then
   __DEBUG=true
fi
##################################################

if [[ $1 == '-k' || $1 == '--keys' ]]
then
    __SETKEYS=true
fi

##################################################
# Colors
# colors for interactive
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[1;33m'
cyan='\e[0;36m'
nc='\e[0m'

reset=${nc}
debug="${yellow} DEBUG: ${reset}" 
warn="${yellow} WARNING: ${reset}" 
success="${green} SUCCESS: ${reset}"
error="${red} ERROR: ${reset}"
question="${cyan} Question: ${reset}"
info="${cyan} INFO: ${reset}"
##################################################


##################################################
# Utilities
# Logger
# source bin/logger.sh
# Path and name for log
if [[ ! $__LOGGER_FILEPATH ]] 
then
    echo 'Set Logger Path'
	__LOGGER_FILEPATH="/tmp"
fi
if [[ ! $__LOGGER_FILENAME ]]; then
    __LOGGER_FILENAME="provision.log"
fi

source $__APP_BASEPATH/scripts/logger.sh
logger "${info} Base Path: $__APP_BASEPATH"
#################################################

##################################################
# Configuration
# Users
# hadoop must be first, creates group for remaining hadoop 
users=(
    "hadoop"   
    "hadoopuser"
    "hdfs"
    "yarn"
    "mapred"
)

# Packages
declare -A packages
packages=(
    ["ssh"]=install_ssh
    ["vim"]=install_vim
    ["jdk"]=install_jdk
    ["python"]=install_python
)

# network
# Debug
if [[ $1 == '--debug' || $1 == '-k' || $1 == '--keys' ]] 
then
    if [[ "$#" -ne 3 ]]
    then
        logger "${error} Provide Nodename IP address"
        exit 1
    fi
    nodename=$2
    ipaddr=$3

else
    if [[ "$#" -ne 2 ]]
    then
        logger "${error} Provide Nodename IP address"
        exit 1
    fi
    nodename=$1
    ipaddr=$2
fi
    
networkcfg=(
    ${nodename}
    ${ipaddr}
    "192.168.56.1"
    "255.255.255.0"
)

if [[ -f "/etc/os-release" ]]
then
    . /etc/os-release
    __OS=$NAME
    if [[ ${__OS} == "CentOS Linux" ]]
    then
        __PKGMGR="yum"
    fi
fi

logger "${info} OS Version: $__OS"
logger "${info} Install via ${__PKGMGR}"

logger "${info} Configure Node: ${networkcfg[0]} ${networkcfg[1]} ${networkcfg[2]} ${networkcfg[3]}"

logger "${info} Packages to Install:"
for key in "${!packages[@]}"
do
    logger "${info} Install ${key}"
done

logger "${info} Users to configure:"
for user in ${users[@]}
do
    logger "${info} ${user}"
done
################################################

# Pass sudo command
# $ param str Command
executor() {
    COMMAND="$@"
    if [[ $__DEBUG == true ]]; then
        logger "${debug} $@"
    else
        logger "${info} Execute $@"
        ${COMMAND[@]} 
    fi
}

################################################

##################################################
if [[ ! -d ${__SHARE_FILEPATH} ]]
then 
    # Start Provision Process
    logger "${info} Begin provisioning"
    source $__APP_BASEPATH/scripts/vboxshare.sh
    
    #################################################
    # Networking
    source $__APP_BASEPATH/scripts/network.sh

    # Users
    source $__APP_BASEPATH/scripts/users.sh
    ################################################
    logger "${info} Completed initial provisioning, restarting"
    executor "sudo reboot"
else
    # Use the vmshare to indicate VM has restarted
    # Better way is to store script state
    # run from init.d
    # Complete installation with users
    # Start Provision Process
    logger "${info} Complete provisioning"
    
    ###################################################
    # Packages
    source $__APP_BASEPATH/scripts/packages.sh

    #################################################
    # SSH KEYS
    #################################################
    source $__APP_BASEPATH/scripts/keys.sh
    #################################################
    # Hadoop
    source $__APP_BASEPATH/scripts/hadoop.sh

    logger "${info} Completed Provisioning Process"

    exit 0
fi
##################################################

##################################################

if [[ $__SETKEYS == true ]]
then
    logger "${info} ============================================ " 
    logger "${info} set hosts"
    sudo cat $__SHARE_FILEPATH/$__HOSTS_FILENAME | sudo tee -a /etc/hosts
    
    logger "${info} copy keys to slaves"
    for user in ${users[@]}
    do
         sudo -u ${user} cat $__SHARE_FILEPATH/$__KEYS_FILENAME | tee -a /home/${user}/.ssh/authorized_keys
    done
    exit 0
fi 

exit 0
