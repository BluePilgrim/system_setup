#
# Dockerfile for marathon
#
# docker build -t cluster/marathon .
#
FROM cluster/mesos:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# Setup
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

# Add the repository
RUN echo "deb http://repos.mesosphere.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) main" | \
  tee /etc/apt/sources.list.d/mesosphere.list

# Install packages
RUN apt-get -y update &&  apt-get -y install marathon chronos
RUN locale-gen en_US.UTF-8 > /dev/null 2>&1

EXPOSE 9090
ENTRYPOINT java -Xmx512m -Djava.library.path=/usr/local/lib -Djava.util.logging.SimpleFormatter.format='%2$s %5$s%6$s%n' -cp /usr/bin/marathon mesosphere.marathon.Main --http_port 9090 --zk $MARATHON_ZK --master $MESOS_MASTER
