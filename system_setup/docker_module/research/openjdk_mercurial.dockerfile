#
# Dockerfile for OpenJDK source build environment
#
# name : research/openjdk
#

FROM research/base
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# install mercurial and bootstrap components
RUN \
  apt-get install -y software-properties-common python-software-properties && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-key 323293EE && \
  add-apt-repository -y ppa:mercurial-ppa/releases && \
  apt-get update && \
  apt-get install -y mercurial && \
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

# check out open jdk 8u60
RUN \
  cd /root && hg clone http://hg.openjdk.java.net/jdk8u/jdk8u60 && cd jdk8u60 && sh get_source.sh && \
  ln -s /root/jdk8u60 /root/jdk8

# build the open jdk system as a base
RUN \
  cd /root/jdk8 && \
  bash ./configure && \
  sed -i '/^SUPPORTED_OS_VERSION/ s:.*:\#&\nDISABLE_HOTSPOT_OS_VERSION_CHECK=ok:' hotspot/make/linux/Makefile && \
  make all

# install OpenFX system
#RUN \
#  apt-get install -y bison flex gperf libasound2-dev libgl1-mesa-dev \
#    libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libjpeg-dev \
#    libpng-dev libx11-dev libxml2-dev libxslt1-dev libxt-dev \
#    libxxf86vm-dev pkg-config qt4-qmake x11proto-core-dev \
#    x11proto-xf86vidmode-dev libavcodec-dev mercurial libgtk2.0-dev \
#    ksh libxtst-dev libudev-dev && \
#    wget http://services.gradle.org/distributions/gradle-1.8-all.zip -O /root/gradle.zip && unzip -o -d /usr/local /root/gradle.zip && rm /root/gradle.zip && \
#    ln -s /usr/local/gradle-1.8/bin/gradle /usr/local/bin/gradle && \
#    cd /root && hg clone http://hg.openjdk.java.net/openjfx/8u60/rt && \
#    cd /root/rt && sed -i '/compileJava.dependsOn/s:verifyJava:\ :' build.gradle && gradle

# enable the support for JITWatch
RUN \
  cd /root/jdk8/hotspot/src/share/tools/hsdis && \
  wget -qO- http://ftp.heanet.ie/mirrors/gnu/binutils/binutils-2.23.2.tar.gz | tar -xz && \
  apt-get install -y libgmp-dev libmpfr-dev libmpc-dev g++-multilib && \
  sed -i -e 's/@colophon/@@colophon/' -e 's/doc@cygnus.com/doc@@cygnus.com/' binutils-2.23.2/bfd/doc/bfd.texinfo && \
  make BINUTILS=binutils-2.23.2 ARCH=amd64 && \
  cp build/linux-amd64/hsdis-amd64.so /usr/lib/jvm/java-8-oracle/jre/lib/amd64/server/

# install JITWatch
RUN \
  cd /root && git clone https://github.com/AdoptOpenJDK/jitwatch.git && \
  cd /root/jitwatch && mvn clean compile test

# WORKDIR /root
# CMD ["/bin/bash"]
