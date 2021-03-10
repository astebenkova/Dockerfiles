#!/bin/bash

set -ex

createrepo /data/centos/packages

exec "$@"
