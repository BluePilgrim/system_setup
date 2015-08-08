#!/bin/bash
docker build -t research/base - < research.dockerfile
docker build -t research/openjdk - < openjdk.dockerfile
docker build -t research/openjdk_build - < openjdk_build.dockerfile
