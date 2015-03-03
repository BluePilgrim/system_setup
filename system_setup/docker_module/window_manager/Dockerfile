# Xorg Windows Manager
FROM ubuntu:latest
MAINTAINER David Yang <david.yang@mentisware.com>
RUN apt-get update && apt-get install -y openbox
ENV DISPLAY 172.17.42.1:0
ENTRYPOINT ["/usr/bin/openbox"]

