FROM centos:7

RUN yum install -y epel-release && \                                            
    yum update -y && \                                                          
    yum-config-manager --enable cr && \
    yum install -y yum-utils createrepo nginx && \
    yum clean all

VOLUME /data/centos/packages

COPY conf/repo-nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
