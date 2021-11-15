FROM nginx:alpine

ARG DOCKERIZE_VERSION=v0.6.1

ADD https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz /tmp
RUN tar -xvzf /tmp/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz -C /usr/local/bin && \
    rm /tmp/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

COPY entrypoint.sh config.tmpl /

ENTRYPOINT ["/entrypoint.sh"]
