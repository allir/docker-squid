#!/usr/bin/env bash
set -euo pipefail

CN=${CN:-Squid CA}
O=${O:-Squid}
OU=${OU:-Network}
C=${C:-US}

# This is pretty ugly, but it works on macOS without requiring coreutils for GNU readlink. Ideally this would be:
# SCRIPT=$( readlink -f ${BASH_SOURCE[0]} )
SCRIPT=$( cd "$(dirname ${BASH_SOURCE[0]})" &>/dev/null && pwd )/$( basename ${BASH_SOURCE[0]} )
SCRIPTPATH=$( dirname ${SCRIPT} )

generate_ca() {
        if [ ! -f ${SCRIPTPATH}/ca.key ]; then
                echo "Generating new CA..."
                openssl req -new -newkey rsa:2048 -sha256 -days 3650 -nodes -x509 \
                        -config ${SCRIPTPATH}/openssl.cnf -extensions v3_ca \
            -keyout ${SCRIPTPATH}/ca.key -out ${SCRIPTPATH}/ca.pem \
                        -subj "/CN=$CN/O=$O/OU=$OU/C=$C" -utf8 -nameopt multiline,utf8
        else
                echo "CA Found..."
        fi
}

echo "Deploying Squid Proxy..."

generate_ca

echo "Creating Namespace..."
kubectl create namespace proxy || true
echo "Creating Secret..."
kubectl -n proxy create secret generic squid-cert --from-file=${SCRIPTPATH}/ca.key --from-file=${SCRIPTPATH}/ca.pem  --dry-run=client -o yaml | sed '/creationTimestamp/d' | kubectl apply -f -
echo "Creating ConfigMap..."
kubectl -n proxy create configmap squid-config --from-file=${SCRIPTPATH}/squid.conf --dry-run=client -o yaml | sed '/creationTimestamp/d' | kubectl apply -f -
echo "Creating Squid Deployment..."
kubectl -n proxy apply -f ${SCRIPTPATH}/../kubernetes/deployment.yaml -f ${SCRIPTPATH}/../kubernetes/service.yaml

echo "Done"
