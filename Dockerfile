# syntax=docker/dockerfile:1

ARG BASE_IMAGE=debian:12-slim
ARG SQUID_VERSION=5.7

FROM --platform=$TARGETPLATFORM $BASE_IMAGE
LABEL maintainer="Aðalsteinn Rúnarsson <alli@allir.io>"

ENV SQUID_VERSION=$SQUID_VERSION \
    SQUID_CONFIG=/etc/squid/squid.conf \
    SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_USER=proxy \
    SQUID_CERT_DB_GENERATE=true \
    SQUID_CERT_DB_SIZE=4MB

RUN apt-get -q update \
 && DEBIAN_FRONTEND=noninteractive apt-get -q install --no-install-recommends -y \
   squid-openssl=$SQUID_VERSION* \
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
