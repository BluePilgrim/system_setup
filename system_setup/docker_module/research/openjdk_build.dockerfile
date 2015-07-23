#
# Dockerfile for OpenJDK source build environment
#
# name : research/openjdk
#

FROM ubuntu_dev/base:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# install mercurial
RUN \
  apt-get install -y software-properties-common python-software-properties && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-key 323293EE && \
  add-apt-repository -y ppa:mercurial-ppa/releases && \
  apt-get update && \
  apt-get install -y \
                  openjdk-7-jdk \
                  zip libX11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev \
                  libcups2-dev libfreetype6-dev libasound2-dev \
                  mercurial && \
  echo "[ui]" > /root/.hgrc && echo "username=davidyang" >> /root/.hgrc

# ENV JAVA_HOME /usr/lib/jvm/default-java

# check out open jdk 8u40
RUN cd /root && hg clone http://hg.openjdk.java.net/jdk8u/jdk8u40 && cd jdk8u40 && sh get_source.sh

# build the open jdk system
RUN \
  cd /root/jdk8u40 && \
  bash ./configure && \
  DISABLE_HOTSPOT_OS_VERSION_CHECK=ok make all
