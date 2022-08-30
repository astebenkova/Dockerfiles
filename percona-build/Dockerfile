FROM docker-dev-local.docker.mirantis.net/mirantis/openstack-ci/packaging:trusty-amd64

RUN apt-get update && apt-get upgrade && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
COPY run-build-stage.sh /srv/run-build-stage.sh
