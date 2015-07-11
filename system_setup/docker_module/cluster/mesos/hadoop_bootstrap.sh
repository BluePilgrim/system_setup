#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}
: ${JAVA_HOME:=/usr/share/jvm/default-java}
: ${HOST_IP:=`hostname -i`}
$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
# sed -i '/<value>/ s:.*:\t\t<value>hdfs\:$HOST_IP\:9000<\/value>:' $HADOOP_PREFIX/etc/hadoop/core-site.xml
sed -r -i -e s/localhost/$HOST_IP/ -e 's/[[:alnum:]]{1,3}\.[[:alnum:]]{1,3}\.[[:alnum:]]{1,3}\.[[:alnum:]]{1,3}/'$HOST_IP'/' $HADOOP_PREFIX/etc/hadoop/core-site.xml

service ssh start
$HADOOP_PREFIX/sbin/start-dfs.sh
# $HADOOP_PREFIX/sbin/start-yarn.sh

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
