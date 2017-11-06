#! /bin/bash
#
# packages.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.white4@canada.ca>
#
#

# Installers
install_ssh() {
    executor "sudo ${__PKGMGR} install ssh"
}

install_vim() {
    executor "sudo ${__PKGMGR} install vim"
}

install_jdk() {
    if [[ ${__OS} == "CentOS Linux" ]]
    then
        executor "sudo ${__PKGMGR} install --disablerepo=extras,updates java-sdk"
    else
        executor "sudo ${__PKGMGR} install default-jdk"
    fi
}

install_python() {
    executor "sudo ${__PKGMGR} install python3"
}


# Repository from local share drive
tmppath=$(echo $__SHARE_FILEPATH | perl -pe 's/\//\\\//g')
sudo perl -i -pe "s/\#baseurl=http:\/\/mirror.centos.org\/centos\/\$releasever/baseurl=file:$tmppath\/CentOS\//g" /etc/yum.repos.d/CentOS-Base.repo 

# Packages 
logger "${info} Install Packages"
for i in "${packages[@]}"
do
    logger "${info} Installing ${i}"
    ${i}
done

