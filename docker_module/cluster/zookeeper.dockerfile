#
# Dockerfile for zookeeper
#
# Create snapshot builds with:
# docker build -t cluster/zookeeper .
#
FROM ubuntu_dev/full:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

RUN apt-get update && apt-get -y install zookeeperd

EXPOSE 2181 2888 3888

COPY ./zookeeper_bootstrap.sh /usr/local/bin/zookeeper_bootstrap.sh

ENTRYPOINT ["/usr/local/bin/zookeeper_bootstrap.sh"]
