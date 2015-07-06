#
# Dockerfile for base source build environment
# name - ubuntu_dev/base
#
FROM ubuntu:14.04
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

# build packages
RUN apt-get update && apt-get install -y \
	build-essential autoconf libtool zlib1g-dev \
	git libcurl4-nss-dev libsasl2-dev \
	maven \
	python-dev python-boto \
	libsvn-dev libapr1-dev

# export environment
ENV CFLAGS '-O2'
ENV CXXFLAGS '-O2'
