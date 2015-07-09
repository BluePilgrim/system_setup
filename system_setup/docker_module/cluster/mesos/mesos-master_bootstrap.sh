#!/bin/bash

# PUBIC_IP, ZOOKEEPER, QUORUM_VAL, NAME, and PORT will be given via -e option of docker run.

mesos-master --ip=${PUBLIC_IP} --work_dir=/var/lib/mesos --log_dir=/var/log/mesos --quorum=${QUORUM_VAL} --zk=zk://${ZOOKEEPER}/mesos --cluster="Cloud Arda" --hostname=${NAME} --port=${PORT} --registry_fetch_timeout=5mins --registry=in_memory
