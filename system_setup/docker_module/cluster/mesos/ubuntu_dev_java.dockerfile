#
# Dockerfile for source build environment
#
# name : ubuntu_dev/java
# this dockerfile doest not work acutally, because the install scripts requires some interaction.
#

FROM ubuntu_dev/base:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# build packages
RUN \
  apt-get install -y software-properties-common python-software-properties && add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  apt-get install -y oracle-java8-installer && \
  apt-get install -y oracle-java8-set-default && \
  rm -rf /var/cache/oracle-jdk8-installer

# export environment
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
RUN echo JAVA_HOME=$JAVA_HOME
CMD ["/bin/bash"]
