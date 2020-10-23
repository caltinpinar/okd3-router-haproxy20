FROM openshift/origin-haproxy-router:v3.11

USER 0

COPY ius-7.repo /etc/yum.repos.d/
COPY reload-haproxy /var/lib/haproxy/
COPY haproxy-config.template /var/lib/haproxy/conf

RUN set -x && \
    yum -y erase haproxy haproxy18 && \
    yum -y update && \
    INSTALL_PKGS="haproxy20 rsyslog sysvinit-tools" && \
    yum install -y $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all && \
    setcap 'cap_net_bind_service=ep' /usr/sbin/haproxy && \
    chown -R :0 /var/lib/haproxy && \
    chmod -R g+w /var/lib/haproxy

USER 1001

RUN mkdir -p /var/lib/haproxy/router/{certs,cacerts,whitelists} && \
    mkdir -p /var/lib/haproxy/{conf/.tmp,run,bin,log} && \
    touch /var/lib/haproxy/conf/{{os_http_be,os_edge_reencrypt_be,os_tcp_be,os_sni_passthrough,os_route_http_redirect,cert_config,os_wildcard_domain}.map,haproxy.config}

EXPOSE 80 443
WORKDIR /var/lib/haproxy
ENV TEMPLATE_FILE=/var/lib/haproxy/conf/haproxy-config.template \
    RELOAD_SCRIPT=/var/lib/haproxy/reload-haproxy
ENTRYPOINT ["/usr/bin/openshift-router", "--v=2"]
