#!/usr/bin/env sh

# if arguements are less than 2 quit

RUNNER="$1"
MODE="$2"
if [ "$3" == "" ];then
  PORT="5000"
else
  PORT="$3"
fi

if [ "$MODE" == "docker" ]; then
  docker kill $(docker ps -q)
else
  if [ "$RUNNER" == "localstack" ]; then
    localstack stop &
  elif [ "$RUNNER" == "moto" ]; then
    ps aux | grep moto | grep -v grep | awk -F ' ' '{print $2}' | xargs kill -9
  fi
fi

# Update profile/config
unalias aws

echo "Remove the providers.tf file"
