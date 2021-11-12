FROM debian:11-slim
LABEL maintainer="Aðalsteinn Rúnarsson <alli@allir.io>"

ENV SQUID_VERSION=4.13 \
    SQUID_CONFIG=/etc/squid/squid.conf \
    SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_USER=proxy \
    SQUID_CERT_DB_GENERATE=true \
    SQUID_CERT_DB_SIZE=4MB

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
   squid-openssl=${SQUID_VERSION}* \
   ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN sed '/^#http_access allow localnet/s/^#//' -i /etc/squid/squid.conf \
  && mkdir -p /var/run/squid \
  && chown -R ${SQUID_USER}:${SQUID_USER} /var/run/squid

COPY conf.d/ /etc/squid/conf.d/
COPY entrypoint.sh /usr/sbin/entrypoint.sh

EXPOSE 3128/tcp
USER ${SQUID_USER}
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
