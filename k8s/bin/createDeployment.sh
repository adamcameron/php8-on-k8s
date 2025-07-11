#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOYMENT_YAML="$SCRIPT_DIR/../deployment.yaml"

kubectl apply -f "$DEPLOYMENT_YAML"

HOST_IP=$(ip route | awk '/default/ { print $3 }')
if [ -z "$HOST_IP" ]; then
  echo "Could not determine host IP"
  exit 1
fi

kubectl set env deployment/php MYSQL_HOST=$HOST_IP
