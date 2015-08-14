#!/bin/bash

# ZOOKEEPER and PUBLIC_IP will be given via -e option of docker run.

: ${MESOS_SLAVE_OPTS:="--ip=${PUBLIC_IP} --master=zk://${ZOOKEEPER}/mesos --containerizers=docker,mesos --executor_registration_timeout=5mins"}

mesos-slave $MESOS_SLAVE_OPTS
