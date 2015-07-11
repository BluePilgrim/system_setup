#!/bin/bash

# PUBIC_IP, ZOOKEEPER, QUORUM_VAL, NAME, and PORT will be given via -e option of docker run.

: ${MESOS_MASTER_OPTS:="--ip=${PUBLIC_IP} --work_dir=/var/lib/mesos --log_dir=/var/log/mesos --quorum=${QUORUM_VAL} --zk=zk://${ZOOKEEPER}/mesos --cluster='Cloud Arda' --registry_fetch_timeout=5mins --registry=in_memory"}

mesos-master --port=${PORT} --hostname=${NAME} ${MESOS_MASTER_OPTS}
