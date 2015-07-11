#!/bin/bash

# currently, this is mainly for the cluster setup for the mac mini of my home, which is the only stationary server.
# Since I want to make a scalable cluster system, the configuration will be as follows based on docker containers.
# = one zookeeper container
# = three mesos master containers whose listening ports will be mapped to 5050, 15050, and 25050.
# = one mesos slave container
# = one marathon container

# assume that PRIMARY_SERVER is already set to address of the server.
#PRIMARY_SERVER=$(hostname)
# : ${PRIMARY_SERVER:=`hostname -i | sed -e 's/ $//'`}

# set up options for each node
ZOOKEEPER=${PRIMARY_SERVER}:2181
QUORUM_VAL=2

MESOS_SLAVE_OPTS="--ip=${PRIMARY_SERVER} --master=zk://${ZOOKEEPER}/mesos --containerizers=docker,mesos --executor_registration_timeout=5mins"
MESOS_MASTER_OPTS="--ip=${PRIMARY_SERVER} --work_dir=/var/lib/mesos --log_dir=/var/log/mesos --quorum=${QUORUM_VAL} --zk=zk://${ZOOKEEPER}/mesos --cluster='Cloud Arda' --registry_fetch_timeout=5mins --registry=in_memory"
MARATHON_OPTS="--http_port 9090 --zk zk://$ZOOKEEPER/marathon --master zk://$ZOOKEEPER/mesos --webui_url http://${PRIMARY_SERVER}:9090"
echo Bootstrapping a cluster at ${PRIMARY_SERVER}
echo MESOS_SLAVE_OPTS=${MESOS_SLAVE_OPTS}
echo MESOS_MASTER_OPTS=${MESOS_MASTER_OPTS}
echo MARATHON_OPTS=${MARATHON_OPTS}

# create the zookeeper
docker run -d -p 2181:2181 -p 2888:2888 -p 3888:3888 --name=zookeeper -e SERVER_LIST=${PRIMARY_SERVER} -e ZK_ID=1 cluster/mesosphere /usr/local/bin/zookeeper_bootstrap.sh
# wait for the zookeeper launch
sleep 1
echo Launched ZooKeeper Service at ${ZOOKEEPER}

# create one mesos slave first because the launch may stop mesos-master
docker run -d -p 5051:5051 --name=mesos_slave1 --net=host --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /sys:/sys -e PUBLIC_IP=${PRIMARY_SERVER} -e ZOOKEEPER=${ZOOKEEPER} -e MESOS_SLAVE_OPTS="${MESOS_SLAVE_OPTS}" cluster/mesosphere /usr/local/bin/mesos-slave_bootstrap.sh
echo "Created mesos slave..."

# create three mesos masters
#QUORUM_VAL=2
#QUORUM_VAL=1
docker run -d -p 5050:5050 --name=mesos_master1 --net=host -e PUBLIC_IP=${PRIMARY_SERVER} -e ZOOKEEPER=${ZOOKEEPER} -e QUORUM_VAL=${QUORUM_VAL} -e NAME="Mesos Master 1" -e PORT=5050 -e MESOS_MASTER_OPTS="${MESOS_MASTER_OPTS}" cluster/mesosphere /usr/local/bin/mesos-master_bootstrap.sh
echo "Created mesos master 1..."

docker run -d -p 15050:5050 --name=mesos_master2 --net=host -e PUBLIC_IP=${PRIMARY_SERVER} -e ZOOKEEPER=${ZOOKEEPER} -e QUORUM_VAL=${QUORUM_VAL} -e NAME="Mesos Master 2" -e PORT=15050 -e MESOS_MASTER_OPTS="${MESOS_MASTER_OPTS}" cluster/mesosphere /usr/local/bin/mesos-master_bootstrap.sh
echo "Created mesos master 2..."

docker run -d -p 25050:5050 --name=mesos_master3 --net=host -e PUBLIC_IP=${PRIMARY_SERVER} -e ZOOKEEPER=${ZOOKEEPER} -e QUORUM_VAL=${QUORUM_VAL} -e NAME="Mesos Master 3" -e PORT=25050 -e MESOS_MASTER_OPTS="${MESOS_MASTER_OPTS}" cluster/mesosphere /usr/local/bin/mesos-master_bootstrap.sh
echo "Created mesos master 3..."

# create one marathon
docker run -d -p 9090:9090 --name=marathon -e PUBLIC_IP=${PRIMARY_SERVER} -e ZOOKEEPER=${ZOOKEEPER} -e MARATHON_OPTS="${MARATHON_OPTS}" cluster/mesosphere /usr/local/bin/marathon_bootstrap.sh
echo "Created Marathon..."
