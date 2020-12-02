#!/usr/bin/env bash
docker container stop $(docker container list -a -q) --force
docker container rm $(docker container list -a -q) --force
#docker rmi $(docker image list -a -q) --force
docker volume rm $(docker volume ls -q) --force