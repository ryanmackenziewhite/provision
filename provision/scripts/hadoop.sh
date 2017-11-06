#! /bin/bash
#
# hadoop.sh
# Copyright (C) 2017 Ryan Mackenzie White <ryan.white4@canada.ca>
#


if [[ ! -d $__HADOOP_PATH ]]
then
        executor "sudo mkdir $__HADOOP_PATH"
fi	

executor "sudo tar -xzf $__SHARE_FILEPATH/$__HADOOP_VERSION.tar.gz --directory $__HADOOP_PATH"
executor "sudo chown -R hadoop:hadoop $__HADOOP_PATH/$__HADOOP_VERSION"
##################################################
# Create /etc/profile.d/hadoop.sh
sudo touch /etc/profile.d/hadoop_setup.sh
sudo echo -e "HADOOP_PREFIX=$__HADOOP_PATH/$__HADOOP_VERSION" | sudo tee -a /etc/profile.d/hadoop_setup.sh
sudo echo -e "export HADOOP_PREFIX" | sudo tee -a /etc/profile.d/hadoop_setup.sh
sudo echo -e "JAVA_HOME=/usr" | sudo tee -a /etc/profile.d/hadoop_setup.sh
sudo echo -e "export JAVA_HOME" | sudo tee -a /etc/profile.d/hadoop_setup.sh

echo -e "export PATH=$PATH:$__HADOOP_PATH/$__HADOOP_VERSION/bin:$__HADOOP_PATH/$__HADOOP_VERSION/sbin" | sudo tee -a /etc/environment

# Create the storage directories
# Do we need to create 1...n for datanode and add these directories?
if [[ ${nodename} == "master" ]]
then
    sudo mkdir -p /data/dfs/nn
    sudo chown -R hdfs:hdfs /data/dfs/nn
else
    sudo mkdir -p /data/dfs/dn
    sudo chown -R hdfs:hdfs /data/dfs/dn
fi

# Configure the hadoop environment scripts
# Note that MR and YARN shell scripts overide values in hadoop-env.sh

