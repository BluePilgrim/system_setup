#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}
: ${HOST_IP:=`hostname -i | sed -e 's/ $//'`}
export USER=root

source $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid > /dev/null 2>&1

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# register additional slaves if any (additional slave ip addresses are given by comma separated list in ASLAVES)
# for s in ${ASLAVES//,/ }; do echo "new slave $s is added."; echo $s >> $HADOOP_CONF_DIR/slaves; done;

service ssh start

if [[ $1 == "-d" ]]; then
  echo slave node is launching...
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  echo slave node is launching...
  /bin/bash
fi
