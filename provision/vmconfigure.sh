#! /opt/local/bin/bash
#
# vmconfigure.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.white@cern.ch>
#
# Distributed under terms of the  license.
#
# Virtual Machine creation script
# Usage:
# ./vmconfigure.sh <Mode> <Name> <OS> <Storage in MB> <RAM in MB>

if [[ $1 == 'help' || $1 == '-h' || $1 == '--help' ]] 
then
    echo "Usage:"
    echo "./vmconfigure.sh <Mode> <VMName> <OS> <Storage> <RAM> <NETWORK TYPE>"
    echo "MODE"
    echo "create -- Creates initial VM"
    echo "finalize --  Sets boot order and attaches Guest Additions"
    echo "NETWORK TYPE:"
    echo "nat"
    echo "bridged"
    exit 1
fi

MODE=$1
VM_NAME=$2
OS_FLAVOR=$3
STORAGE=$4
RAM=$5
NET_TYPE=$6
NET_ADAPTER="82540EM"
SHARE_PATH="/Users/rwhite/Downloads/vmshare"
#IMAGE="mini.iso
#IMAGE="CentOS-7-x86_64-Minimal-1708.iso"
IMAGE="CentOS-7-x86_64-DVD-1708.iso"
if [[ ${MODE} == 'create' ]]
then
    VBoxManage createhd --filename "${VM_NAME}.vdi" --size ${STORAGE}
    VBoxManage createvm --name ${VM_NAME} --ostype "${OSFLAVOR}" --register
    VBoxManage storagectl ${VM_NAME} --name "SATA Controller" --add sata --controller IntelAHCI
    VBoxManage storageattach ${VM_NAME} --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VM_NAME}.vdi"
    VBoxManage storagectl ${VM_NAME} --name "IDE Controller" --add ide
    VBoxManage storageattach ${VM_NAME} --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "/Users/rwhite/Downloads/$IMAGE"
    #VBoxManage storageattach ${VM_NAME} --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "additions"
    VBoxManage modifyvm ${VM_NAME} --ioapic on
    VBoxManage modifyvm ${VM_NAME} --boot1 dvd --boot2 disk --boot3 none --boot3 none --boot4 none
    VBoxManage modifyvm ${VM_NAME} --memory $RAM --vram 128
    if [[ $NET_TYPE ==  "bridged" ]]
    then
        VBoxManage modifyvm $VM_NAME --nic1 bridged --bridgeadapter1 ${NET_ADAPTER}
    elif
        [[ ${NET_TYPE} == "nat" ]]
    then
        VBoxManage modifyvm ${VM_NAME} --nic1 nat --nictype1 ${NET_ADAPTER} 
    else
        echo -e "ERROR: Network type not specified"
        exit 1
    fi
    VBoxManage modifyvm ${VM_NAME} --cableconnected1 on
    VBoxManage modifyvm ${VM_NAME} --natdnshostresolver1 on
    VBoxManage modifyvm ${VM_NAME} --natpf1 "guestssh,tcp,,2222,,22"
    VBoxManage modifyvm ${VM_NAME} --nic2 hostonly --nictype2 ${NET_ADAPTER} --hostonlyadapter2 "vboxnet0"
    VBoxManage modifyvm ${VM_NAME} --cableconnected1 on
    VBoxManage sharedfolder add ${VM_NAME} --name vmshare --hostpath ${SHARE_PATH} --automount
    VBoxManage startvm ${VM_NAME}
elif [[ ${MODE} == "finalize" ]]
    then
    VBoxManage controlvm ${VM_NAME} poweroff
    sleep 10
    VBoxManage modifyvm ${VM_NAME} --boot1 disk --boot2 dvd --boot3 none --boot4 none
    VBoxManage storageattach ${VM_NAME} --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "additions"
    VBoxManage startvm ${VM_NAME}
else 
    echo -e "ERROR: Mode not specified"
fi

# Mount GuestAdditions, replaces the original iso
# VBoxManage storageattach {VM_NAME} --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "additions"
# VBoxManage startvm ${VM_NAME}
