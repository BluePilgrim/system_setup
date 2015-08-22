#!/bin/bash
docker rmi research/openjdk
docker rmi ubuntu_dev/base
docker rmi ubuntu_dev/java
docker rmi research/base

cd ../common
docker build -t ubuntu_dev/base - < ubuntu_dev_base.dockerfile
docker build -t ubuntu_dev/java - < ubuntu_dev_java.dockerfile
cd -
cp research.dockerfile Dockerfile && docker build -t research/base . && rm Dockerfile
docker build -t research/openjdk - < openjdk.dockerfile

docker images | grep "<none>" | awk '{print $3;}' | xargs docker rmi
#docker build -t research/openjdk_build - < openjdk_build.dockerfile
