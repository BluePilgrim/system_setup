#
# Dockerfile for OpenJDK build environment
#
# name : research/openjdk_build
#

FROM research/openjdk
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# build the open jdk system
RUN \
  cd /root/jdk8 && \
#  bash ./configure && \
#  sed -i '/^SUPPORTED_OS_VERSION/ s:.*:\#&\nDISABLE_HOTSPOT_OS_VERSION_CHECK=ok:' hotspot/make/linux/Makefile && \
#  make all && make install
  make install

# WORKDIR /root
# CMD ["/bin/bash"]
