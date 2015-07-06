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
RUN apt-get update && sudo apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:webupd8team/java && apt-get install -y oracle-java8-installer

# export environment
RUN apt-get install -y oracle-java8-set-default
