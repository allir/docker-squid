#!/bin/bash
set -e

# allow arguments to be passed to squid
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch squid
if [[ -z ${1} ]]; then
  if [[ ${SQUID_CERT_DB_GENERATE} == "true" ]] && [[ ! -d ${SQUID_CACHE_DIR}/ssl_db ]]; then
    /usr/lib/squid/security_file_certgen -c -s ${SQUID_CACHE_DIR}/ssl_db -M ${SQUID_CERT_DB_SIZE}
  fi
  if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
    echo "Initializing cache..."
    $(which squid) -N -f ${SQUID_CONFIG} -z
  fi
  echo "Starting squid..."
  exec $(which squid) -f ${SQUID_CONFIG} -NYCd 1 ${EXTRA_ARGS}
else
  exec "$@"
fi
