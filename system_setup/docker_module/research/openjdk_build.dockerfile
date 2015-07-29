#
# Dockerfile for OpenJDK source build environment
#
# name : research/openjdk
#

FROM ubuntu_dev/base:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# install mercurial and bootstrap components
RUN \
  apt-get install -y software-properties-common python-software-properties && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-key 323293EE && \
  add-apt-repository -y ppa:mercurial-ppa/releases && \
  apt-get update && \
  apt-get install -y \
                  openjdk-7-jdk \
                  zip wget libX11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev \
                  libcups2-dev libfreetype6-dev libasound2-dev \
                  gdb mercurial && \
  wget -qO- https://adopt-openjdk.ci.cloudbees.com/view/OpenJDK/job/jtreg/lastSuccessfulBuild/artifact/jtreg-4.1-b12.tar.gz | tar -xz -C /usr/local && \
  mkdir -p /usr/local/jtreg/linux && ln -s /usr/local/jtreg/bin /usr/local/jtreg/linux/bin && \
  mkdir -p /usr/local/jtreg/win32 && ln -s /usr/local/jtreg/bin /usr/local/jtreg/win32/bin && \
  ln -s /usr/local/jtreg/bin/jtreg /usr/local/bin/jtreg && \
  echo "[ui]" > /root/.hgrc && echo "username=davidyang" >> /root/.hgrc

# ENV JAVA_HOME /usr/lib/jvm/default-java

# install Eclipse CDT Environment
RUN \
  wget -qO- http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/mars/R/eclipse-cpp-mars-R-linux-gtk-x86_64.tar.gz | tar -xz -C /usr/local && \
  ln -s /usr/local/eclipse/eclipse /usr/local/bin/eclipse

# check out open jdk 8u40
RUN \
  cd /root && hg clone http://hg.openjdk.java.net/jdk8u/jdk8u40 && cd jdk8u40 && sh get_source.sh && \
  ln -s /root/jdk8u40 /root/jdk8

# build the open jdk system
RUN \
  cd /root/jdk8 && \
  bash ./configure && \
  sed -i '/^SUPPORTED_OS_VERSION/ s:.*:\#&\nDISABLE_HOTSPOT_OS_VERSION_CHECK=ok:' hotspot/make/linux/Makefile && \
  make all

WORKDIR /root
CMD ["/bin/bash"]
