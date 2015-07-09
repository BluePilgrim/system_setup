#!/bin/bash

ZOOKEEPER=${PRIMARY_SERVER}:2181
PUBLIC_IP=$(boot2docker ip)

docker run -d -p 5051:5051 --name=mesos_slave1 --net=host --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /sys:/sys -v /var/lib/docker:/var/lib/docker -e PUBLIC_IP=${PUBLIC_IP} -e ZOOKEEPER=${ZOOKEEPER} cluster/mesosphere /usr/local/bin/mesos-slave_bootstrap.sh
