#!/bin/sh

set -e

if [ -z "${DATA_TAG}" ]; then
  echo "Required environment variable DATA_TAG not set."
  echo "You probably want to set it to something like \"registry.weahead.se/<name>-data:latest\""
  echo "Exiting"
  exit 1
fi

if [ ! -S /var/run/docker.sock ]; then
  echo "/var/run/docker.sock not found."
  echo "Have you mounted it properly?"
  echo "Exiting"
  exit 1
fi

exec $1