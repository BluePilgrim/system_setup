#
# Dockerfile for all-in-one package of mesos, marathon, chronus, and zookeeper
#
# docker build -t cluster/mesosphere .
#
FROM ubuntu_dev/full:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# Setup
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

# Add the repository
RUN echo "deb http://repos.mesosphere.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) main" | \
  tee /etc/apt/sources.list.d/mesosphere.list

# Install packages
RUN apt-get -y update &&  apt-get -y install mesos marathon chronos
RUN locale-gen en_US.UTF-8 > /dev/null 2>&1

# Install bootstrap scripts
COPY zookeeper_bootstrap.sh mesos-slave_bootstrap.sh mesos-master_bootstrap.sh marathon_bootstrap.sh /usr/local/bin/

# EXPOSE 2181 5050 5051 9090
# ENTRYPOINT java -Xmx512m -Djava.library.path=/usr/local/lib -Djava.util.logging.SimpleFormatter.format='%2$s %5$s%6$s%n' -cp /usr/bin/marathon mesosphere.marathon.Main --http_port 9090 --zk $MARATHON_ZK --master $MESOS_MASTER
