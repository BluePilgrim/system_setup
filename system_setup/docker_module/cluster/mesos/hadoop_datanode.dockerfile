#
# Dockerfile for Hadoop in docker container with mesos support
#
# docker build -t cluster/hadoop_namenode .
#
FROM cluster/mesosphere:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# set up ssh environment
RUN apt-get update && apt-get install -y openssh-server

# download native support
# RUN mkdir -p /tmp/native
# RUN wget -q -O- http://dl.bintray.com/sequenceiq/sequenceiq-bin/hadoop-native-64-2.7.0.tar | tar -x -C /tmp/native

# get hadoop 2.7.1
RUN wget -q -O- http://mirror.apache-kr.org/hadoop/common/stable/hadoop-2.7.1.tar.gz | tar -xz -C /usr/local && cd /usr/local && ln -s ./hadoop-2.7.1 hadoop

# set hadoop environment
ENV HADOOP_PREFIX=/usr/local/hadoop \
	HADOOP_COMMON_HOME=/usr/local/hadoop \
	HADOOP_HDFS_HOME=/usr/local/hadoop \
	HADOOP_MAPRED_HOME=/usr/local/hadoop \
	HADOOP_YARN_HOME=/usr/local/hadoop \
	HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop \
	YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop

# modify environment settings
RUN \
  sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/default-java\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
  sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# copy input xml files
RUN mkdir $HADOOP_PREFIX/input && cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

# cluster mode setup
ENV FS_DEFAULTFS=localhost\\:9000 \
	DFS_NAMENODE_NAME_DIR=file\\:///grid1/hadoop/hdfs/nn,file\\:///grid2/hadoop/hdfs/nn \
	DFS_DATANODE_DATA_DIR=file\\:///grid1/hadoop/hdfs/dn,file\\:///grid2/hadoop/hdfs/dn \
	DFS_REPLICATION=1

# set up core-site.xml <- this will be injected by the name node.
# RUN sed -i '/^<configuration>/ s:.*:<configuration>\n\t<property>\n\t\t<name>fs.defaultFS</name>\n\t\t<value>hdfs\://'$FS_DEFAULTFS'</value>\n\t</property>:' $HADOOP_CONF_DIR/core-site.xml && cat $HADOOP_CONF_DIR/core-site.xml

# set up hdfs-site.xml
RUN sed -i '/^<configuration>/ s:.*:<configuration>\n\t<property>\n\t\t<name>dfs.namenode.name.dir</name>\n\t\t<value>'$DFS_NAMENODE_NAME_DIR'</value>\n\t\t<name>dfs.datanode.data.dir</name>\n\t\t<value>'$DFS_DATANODE_DATA_DIR'</value>\n\t\t<name>dfs.replication</name>\n\t\t<value>'$DFS_REPLICATION'</value>\n\t</property>:' $HADOOP_CONF_DIR/hdfs-site.xml && cat $HADOOP_CONF_DIR/hdfs-site.xml

# format HDFS
# RUN $HADOOP_PREFIX/bin/hdfs namenode -format

# set up ssh access env : port is set to 2122
RUN \
  echo y | ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
  echo y | ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
  ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
  cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
  echo "Host *\n  UserKnownHostsFile\t/dev/null\n  StrictHostKeyChecking\tno\n  LogLevel\tquiet\n  Port\t2122" > /root/.ssh/config && \
  chmod 600 /root/.ssh/config && chown root:root /root/.ssh/config && \
  sed -i -e '/^Port/s/22/2122/' -e '/^UsePAM/s:yes:no:' /etc/ssh/sshd_config

RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh

# set up bootstrap script
ADD hadoop_datanode_bootstrap.sh /usr/local/bin/hadoop_datanode_bootstrap.sh
RUN chown root:root /usr/local/bin/hadoop_datanode_bootstrap.sh && chmod 700 /usr/local/bin/hadoop_datanode_bootstrap.sh

CMD ["/usr/local/bin/hadoop_datanode_bootstrap.sh", "-d"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 \
# Mapred ports
	19888 \
#Yarn ports
	8030 8031 8032 8033 8040 8042 8088 \
#Other ports
	49707 2122
