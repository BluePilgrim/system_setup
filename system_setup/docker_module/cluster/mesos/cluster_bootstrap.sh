#!/bin/bash

# currently, this is mainly for the cluster setup for the mac mini of my home, which is the only stationary server.
# Since I want to make a scalable cluster system, the configuration will be as follows based on docker containers.
# = one zookeeper container
# = three mesos master containers whose listening ports will be mapped to 5050, 15050, and 25050.
# = one mesos slave container
# = one marathon container

# assume that PRIMARY_SERVER is already set to address of the server.
#PRIMARY_SERVER=$(hostname)
echo Bootstrapping a cluster at ${PRIMARY_SERVER}

# create the zookeeper
docker run -d -p 2181:2181 -p 2888:2888 -p 3888:3888 --name=zookeeper -e SERVER_LIST=${PRIMARY_SERVER} -e ZK_ID=1 cluster/mesosphere /usr/local/bin/zookeeper_bootstrap.sh

# wait for the zookeeper launch
sleep 1

ZOOKEEPER=${PRIMARY_SERVER}:2181
echo Launched ZooKeeper Service at ${ZOOKEEPER}

# create one mesos slave first because the launch may stop mesos-master
docker run -d -p 5051:5051 --name=mesos_slave1 --net=host --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /sys:/sys -e PUBLIC_IP=${PRIMARY_SERVER} -e ZOOKEEPER=${ZOOKEEPER} cluster/mesosphere /usr/local/bin/mesos-slave_bootstrap.sh
echo "Created mesos slave..."

# create three mesos masters
QUORUM_VAL=2
#QUORUM_VAL=1
docker run -d -p 5050:5050 --name=mesos_master1 --net=host -e PUBLIC_IP=${PRIMARY_SERVER} -e ZOOKEEPER=${ZOOKEEPER} -e QUORUM_VAL=${QUORUM_VAL} -e NAME="Mesos Master 1" -e PORT=5050 cluster/mesosphere /usr/local/bin/mesos-master_bootstrap.sh
echo "Created mesos master 1..."

docker run -d -p 15050:5050 --name=mesos_master2 --net=host -e PUBLIC_IP=${PRIMARY_SERVER} -e ZOOKEEPER=${ZOOKEEPER} -e QUORUM_VAL=${QUORUM_VAL} -e NAME="Mesos Master 2" -e PORT=15050 cluster/mesosphere /usr/local/bin/mesos-master_bootstrap.sh
echo "Created mesos master 2..."

docker run -d -p 25050:5050 --name=mesos_master3 --net=host -e PUBLIC_IP=${PRIMARY_SERVER} -e ZOOKEEPER=${ZOOKEEPER} -e QUORUM_VAL=${QUORUM_VAL} -e NAME="Mesos Master 3" -e PORT=25050 cluster/mesosphere /usr/local/bin/mesos-master_bootstrap.sh
echo "Created mesos master 3..."

# create one marathon
docker run -d -p 9090:9090 --name=marathon --net=host -e ZOOKEEPER=${ZOOKEEPER} cluster/mesosphere /usr/local/bin/marathon_bootstrap.sh
echo "Created Marathon..."
