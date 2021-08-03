FROM centos:7

RUN yum install -y epel-release && \
    yum update -y && \
    yum-config-manager --enable cr && \
    yum install -y yum-utils createrepo nginx gpg2 rpm-sign rng-tools && \
    yum clean all

ARG DOCKERIZE_VERSION=v0.0.4

ADD https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-v0.0.4.tar.gz /tmp
RUN tar -xvzf /tmp/dockerize-linux-amd64-v0.0.4.tar.gz -C /usr/local/bin && \
    rm /tmp/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

RUN echo "HRNGDEVICE=/dev/urandom" > /etc/default/rng-tools

VOLUME /data/centos/packages

COPY conf/repo-nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh conf/repo.tmpl /

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
