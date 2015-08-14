#
# Dockerfile for Spark with Hadoop HDFS
#
# docker build -t cluster/spark .
#
FROM cluster/hadoop_namenode:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# import spart tgz
COPY ./spark-1.4.0-bin-custom-spark.tgz /usr/local/
RUN cd /usr/local && tar xvfz spark-1.4.0-bin-custom-spark.tgz &&  ln -s spark-1.4.0-bin-custom-spark spark
ENV \
  SPARK_HOME=/usr/local/spark \
  PATH=$PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin

RUN \
  service ssh start && \
  $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && \
#  $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && \
  $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME/lib /spark && \
  $HADOOP_PREFIX/bin/hdfs dfs -put /usr/local/spark-1.4.0-bin-custom-spark.tgz /spark/ && \
  rm -f /usr/local/spark-1.4.0-bin-custom-spark.tgz

COPY spark_bootstrap.sh /usr/local/bin/spark_bootstrap.sh
RUN chown root.root /usr/local/bin/spark_bootstrap.sh && chmod 700 /usr/local/bin/spark_bootstrap.sh

CMD ["/usr/local/bin/spark_bootstrap.sh"]
