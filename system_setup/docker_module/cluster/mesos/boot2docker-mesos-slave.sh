#!/bin/bash
docker run -d -p 5051:5051 --name=mesos-slave --net=host --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /sys:/sys -v $(which docker):/usr/local/bin/docker cluster/mesos mesos-slave --master=zk://${ZOOKEEPER}/mesos --containerizers=docker,mesos --docker_mesos_image=cluster/mesos --executor_registration_timeout=5mins --ip=$(boot2docker ip)
