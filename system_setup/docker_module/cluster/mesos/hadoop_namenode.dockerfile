#
# Dockerfile for Hadoop in docker container with mesos support
#
# docker build -t cluster/hadoop_namenode .
#
FROM cluster/hadoop:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# set up core-site.xml
RUN sed -i '/^<configuration>/ s:.*:<configuration>\n\t<property>\n\t\t<name>fs.defaultFS</name>\n\t\t<value>hdfs\://'$FS_DEFAULTFS'</value>\n\t</property>:' $HADOOP_CONF_DIR/core-site.xml && cat $HADOOP_CONF_DIR/core-site.xml

# format HDFS
RUN $HADOOP_PREFIX/bin/hdfs namenode -format

# create root directory
# RUN service ssh start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root

# set up bootstrap script
ADD hadoop_namenode_bootstrap.sh /usr/local/bin/hadoop_namenode_bootstrap.sh
RUN chown root:root /usr/local/bin/hadoop_namenode_bootstrap.sh && chmod 700 /usr/local/bin/hadoop_namenode_bootstrap.sh

CMD ["/usr/local/bin/hadoop_namenode_bootstrap.sh", "-d"]
