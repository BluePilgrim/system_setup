#!/bin/bash

# ZOOKEEPER and PUBLIC_IP will be given via -e option of docker run.

MARATHON_ZK=zk://${ZOOKEEPER}/marathon
MESOS_MASTER=zk://${ZOOKEEPER}/mesos

echo MARATHON_ZK=${MARATHON_ZK}
echo MESOS_MASTER=${MESOS_MASTER}

: ${MARATHON_OPTS:="--http_port 9090 --zk $MARATHON_ZK --master $MESOS_MASTER --webui_url http://$PUBLIC_IP:9090"}
java -Xmx512m -Djava.library.path=/usr/local/lib -Djava.util.logging.SimpleFormatter.format='%2$s %5$s%6$s%n' -cp /usr/bin/marathon mesosphere.marathon.Main $MARATHON_OPTS
