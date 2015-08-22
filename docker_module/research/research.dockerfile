#
# dockerfile for base environment for research
#
#     name : research/base

# FROM ubuntu_dev/base:1.0
FROM ubuntu_dev/java
MAINTAINER David Yang <david.yang@mentisware.com>

USER root

RUN \
  apt-get update && \
  apt-get install -y \
                  gdb emacs hunspell git\
                  zip wget libX11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev \
                  libcups2-dev libfreetype6-dev libasound2-dev \
                  openssh-server texlive-full

# inject the internal identity file and authorized keys
ADD id_internal authorized_keys /root/.ssh/

# set up the environment for ssh connection
RUN \
#  mkdir /root/.ssh && \
  echo "Host *\n  UserKnownHostsFile\t/dev/null\n  StrictHostKeyChecking\tno\n  LogLevel\tquiet\n  Port\t22\n  IdentityFile\t~/.ssh/id_internal\n  IdentityFile\t~/.ssh/id_rsa" > /root/.ssh/config && \
  chmod 600 /root/.ssh/config && chmod 600 /root/.ssh/id_internal && chown root:root /root/.ssh/* && \
  mkdir /var/run/sshd && sed -i -e '/^PermitRootLogin/s:without-password:yes:' -e '/^UsePAM/s:yes:no:' /etc/ssh/sshd_config && \
  echo 'root:research' | chpasswd

# set up the basic git information
RUN \
  git config --global user.name "David Yang" && \
  git config --global user.email "david.yang@mentisware.com"

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
#CMD ["/bin/bash"]
