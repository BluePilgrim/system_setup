#
# Dockerfile for Hadoop in docker container with mesos support
#
# docker build -t cluster/hadoop .
#
FROM cluster/mesosphere:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# set up ssh environment
RUN apt-get update && apt-get install -y openssh-server
RUN echo y | ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN echo y | ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# set java environment
ENV JAVA_HOME /usr/lib/jvm/default-java
ENV PATH $JAVA_HOME/bin:$PATH

# download native support
# RUN mkdir -p /tmp/native
# RUN wget -q -O- http://dl.bintray.com/sequenceiq/sequenceiq-bin/hadoop-native-64-2.7.0.tar | tar -x -C /tmp/native

# get hadoop 2.7.1
RUN wget -q -O- http://mirror.apache-kr.org/hadoop/common/stable/hadoop-2.7.1.tar.gz | tar -xz -C /usr/local && cd /usr/local && ln -s ./hadoop-2.7.1 hadoop

# set hadoop environment
ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

# modify environment settings
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/default-java\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# copy input xml files
RUN mkdir $HADOOP_PREFIX/input && cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

# for test purpose, pseudo-distributed mode is assumed.
RUN sed -i '/^<configuration>/ s:.*:<configuration>\n\t<property>\n\t\t<name>fs.defaultFS</name>\n\t\t<value>hdfs\://localhost\:9000</value>\n\t</property>:' $HADOOP_CONF_DIR/core-site.xml
RUN sed -i '/^<configuration>/ s:.*:<configuration>\n\t<property>\n\t\t<name>dfs.replication</name>\n\t\t<value>1</value>\n\t</property>:' $HADOOP_CONF_DIR/hdfs-site.xml
# RUN sed  '/^<configuration>/ s:.*:<configuration>\n\t<property>\n\t\t<name>mapreduce.framework.name</name>\n\t\t<value>classic</value>\n\t</property>:' $HADOOP_CONF_DIR/mapred-site.xml.template > $HADOOP_CONF_DIR/mapred-site.xml

# format HDFS
RUN $HADOOP_PREFIX/bin/hdfs namenode -format

# set up ssh access env : port is set to 2122
RUN echo "Host *\n  UserKnownHostsFile\t/dev/null\n  StrictHostKeyChecking\tno\n  LogLevel\tquiet\n  Port\t2122" > /root/.ssh/config && chmod 600 /root/.ssh/config && chown root:root /root/.ssh/config
RUN sed -i -e '/^Port/s/22/2122/' -e '/^UsePAM/s:yes:no:' /etc/ssh/sshd_config

RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh

# create root directory
# RUN service ssh start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root && $HADOOP_PREFIX/bin/hdfs dfs -put $HADOOP_PREFIX/etc/hadoop/ input
RUN service ssh start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root

# set up bootstrap script
ADD hadoop_bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && chmod 700 /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 \
# Mapred ports
	19888 \
#Yarn ports
	8030 8031 8032 8033 8040 8042 8088 \
#Other ports
	49707 2122
