#!/bin/bash

# ZOOKEEPER and PUBLIC_IP will be given via -e option of docker run.

mesos-slave --ip=${PUBLIC_IP} --master=zk://${ZOOKEEPER}/mesos --containerizers=docker,mesos --executor_registration_timeout=5mins
