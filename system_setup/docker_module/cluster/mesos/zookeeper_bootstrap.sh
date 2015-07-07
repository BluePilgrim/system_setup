#!/bin/bash

# when running a zookeeper container, SERVER_LIST and ZK_ID should be specified via "-e" option.

# attach zookeeper servers to zoo.cfg
IFS=,
i=1
for server in ${SERVER_LIST}; do
echo server.$i=$server:2888:3888 >> /etc/zookeeper/conf/zoo.cfg
(( i += 1 ))
done

# set zookeeper id
echo ${ZK_ID} > /etc/zookeeper/conf/myid

#service zookeeper start
/usr/share/zookeeper/bin/zkServer.sh start-foreground
