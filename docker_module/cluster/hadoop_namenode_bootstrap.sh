#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}
: ${HOST_IP:=`hostname -i | sed -e 's/ $//'`}
export USER=root

source $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed -r -i -e s/localhost/$HOST_IP/ -e 's/[[:alnum:]]{1,3}\.[[:alnum:]]{1,3}\.[[:alnum:]]{1,3}\.[[:alnum:]]{1,3}/'$HOST_IP'/' $HADOOP_PREFIX/etc/hadoop/core-site.xml

service ssh start

# register slaves (slave ip addresses are given by comma separated list in SLAVES)
# echo default_hadoop_slave >> $HADOOP_CONF_DIR/slaves
# scp $HADOOP_PREFIX/etc/hadoop/core-site.xml default_hadoop_slave:$HADOOP_PREFIX/etc/hadoop/core-site.xml
rm -f $HADOOP_CONF_DIR/slaves
for s in ${SLAVES//,/ }; do
  echo "new slave $s is added."
  echo $s >> $HADOOP_CONF_DIR/slaves
  scp $HADOOP_PREFIX/etc/hadoop/core-site.xml $s:$HADOOP_PREFIX/etc/hadoop/core-site.xml
done


echo master node is launching...
$HADOOP_PREFIX/sbin/start-dfs.sh
# $HADOOP_PREFIX/sbin/start-yarn.sh

$HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/$USER

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
