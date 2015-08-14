#
# Dockerfile for building Mesos from source
#
# Create snapshot builds with:
# docker build -t cluster/mesos .
#
# Run master/slave with:
# docker run cluster/mesos mesos-master [options]
# docker run cluster/mesos mesos-slave [options]
#
FROM ubuntu_dev/full:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# include libmesos on library path
ENV LD_LIBRARY_PATH /usr/local/lib

# RUN mkdir /opt
RUN cd /opt && git clone https://git-wip-us.apache.org/repos/asf/mesos.git

# configure and build
RUN cd /opt/mesos && ./bootstrap && mkdir build

RUN cd /opt/mesos/build && ../configure && make && make install

# cleanup in a single layer
RUN rm -rf /opt/*
