FROM debian:11-slim
LABEL maintainer="Aðalsteinn Rúnarsson <alli@allir.io>"

ENV SQUID_VERSION=4.13 \
    SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=proxy

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
   squid-openssl=${SQUID_VERSION}* \
   ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/sbin/entrypoint.sh

EXPOSE 3128/tcp
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
