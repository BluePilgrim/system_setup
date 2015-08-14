# Browser
FROM ubuntu:latest
MAINTAINER David Yang <david.yang@mentisware.com>
RUN apt-get update && apt-get install -y chromium-browser
ENV DISPLAY 172.17.42.1:0
CMD ["/usr/bin/chromium-browser", "--no-sandbox", "--user-data-dir=/data"]
