#!/bin/bash

# currently, this is mainly for the cluster setup for the mac mini of my home, which is the only stationary server.
# Since I want to make a scalable cluster system, the configuration will be as follows based on docker containers.
# = one zookeeper container
# = three mesos master containers whose listening ports will be mapped to 5050, 15050, and 25050.
# = one mesos slave container
# = one marathon container

# assume that PRIMARY_SERVER is already set to address of the server.

# create the zookeeper
docker run -p 2181:2181 -p 2888:2888 -p 3888:3888 -d -e SERVER_LIST=${PRIMARY_SERVER} -e ZK_ID=1 cluster/zookeeper

# wait for the zookeeper launch
sleep 5

ZOOKEEPER=${PRIMARY_SERVER}:2181
echo "Launched ZooKeeper Service..."

# create three mesos masters
QUORUM_VAL=2
docker run -d -p 5050:5050 --name=mesos-master cluster/mesos mesos-master --work_dir=/var/lib/mesos --log_dir=/var/log/mesos --quorum=${QUORUM_VAL} --zk=zk://${ZOOKEEPER}/mesos --cluster="Cloud Arda" --hostname="Mesos Master 1"
echo "Created mesos master 1..."

docker run -d -p 15050:5050 --name=mesos-master cluster/mesos mesos-master --work_dir=/var/lib/mesos --log_dir=/var/log/mesos --quorum=${QUORUM_VAL} --zk=zk://${ZOOKEEPER}/mesos --cluster="Cloud Arda" --hostname="Mesos Master 2"
echo "Created mesos master 2..."

docker run -d -p 25050:5050 --name=mesos-master cluster/mesos mesos-master --work_dir=/var/lib/mesos --log_dir=/var/log/mesos --quorum=${QUORUM_VAL} --zk=zk://${ZOOKEEPER}/mesos --cluster="Cloud Arda" --hostname="Mesos Master 3"
echo "Created mesos master 3..."

# create one mesos slave
docker run -d -p 5051:5051 –-name=mesos-slave --net=host --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /sys:/sys cluster/mesos mesos-slave --master=zk://${ZOOKEEPER}/mesos --containerizers=docker,mesos --docker_mesos_image=cluster/mesos --executor_registration_timeout=5mins
echo "Created mesos slave..."

# create one marathon slave
docker run -d -p 9090:9090 --name=marathon -e MARATHON_ZK=zk://${ZOOKEEPER}/marathon -e MESOS_MASTER=zk://${ZOOKEEPER}/mesos cluster/marathon
echo "Created Marathon..."
