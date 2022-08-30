#!/bin/bash

SCRIPT=`realpath $0`
SCRIPT_DIR=`dirname ${SCRIPT}`

## Only build from main folder
cd ${SCRIPT_DIR}

IMAGE="packaging"
ARCH="amd64"
DISTRO=${DISTRO:-trusty}
REGISTRY_URI="airship.svc.mirantis.net/mirantis/percona/"

# Build the image
docker build ./ -f ./Dockerfile -t ${REGISTRY_URI}${IMAGE}:${DISTRO}-${ARCH}
