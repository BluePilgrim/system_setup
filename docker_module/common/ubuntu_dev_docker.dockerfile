#
# Dockerfile for source build environment
#
# name : ubuntu_dev/docker
#
FROM ubuntu_dev/java:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# build packages
RUN apt-get update && apt-get install -y wget && \
	wget -qO- https://get.docker.com/ | sh
