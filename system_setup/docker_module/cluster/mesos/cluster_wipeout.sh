#!/bin/bash
echo stopping the cluster components...
docker stop marathon
docker stop mesos_master1
docker stop mesos_master2
docker stop mesos_master3
docker stop mesos_slave1
docker stop zookeeper

echo removing containers...
docker rm marathon
docker rm mesos_master1
docker rm mesos_master2
docker rm mesos_master3
docker rm mesos_slave1
docker rm zookeeper
