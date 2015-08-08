#
# dockerfile for base environment for research
#
#     name : research/base

# FROM ubuntu_dev/base:1.0
FROM ubuntu_dev/java:1.0
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

RUN \
  apt-get update && \
  apt-get install -y \
                  gdb emacs hunspell git\
                  zip wget libX11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev \
                  libcups2-dev libfreetype6-dev libasound2-dev \
                  openssh-server texlive-full

RUN mkdir /root/.ssh && echo "Host *\n  UserKnownHostsFile\t/dev/null\n  StrictHostKeyChecking\tno\n  LogLevel\tquiet\n  Port\t22" > /root/.ssh/config && chmod 600 /root/.ssh/config && chown root:root /root/.ssh/config
RUN mkdir /var/run/sshd && sed -i -e '/^PermitRootLogin/s:without-password:yes:'  -e '/^UsePAM/s:yes:no:' /etc/ssh/sshd_config
RUN echo 'root:research' | chpasswd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
#CMD ["/bin/bash"]
