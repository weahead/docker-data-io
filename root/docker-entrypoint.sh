#!/bin/sh

set -e

if [ -d /run/secrets ]; then
  for file in /run/secrets/*; do
    VARNAME=$(basename ${file})
    VARVALUE=$(cat ${file})
    export "${VARNAME}"="${VARVALUE}"
  done
fi

if [ -z "${DATA_TAG}" -a -z "${DATA_S3_DST}" ]; then
  echo "Missing both environment variables DATA_TAG and DATA_S3_DST."
  echo "One of them is required."
  echo "Aborting!"
  exit 1
fi

if [ -n "${DATA_TAG}" -a ! -S /var/run/docker.sock ]; then
  echo "/var/run/docker.sock not found."
  echo "Have you mounted it properly?"
  echo "Exiting"
  exit 1
fi

exec $1
