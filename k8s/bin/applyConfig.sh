#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$SCRIPT_DIR/php-config.yaml"
kubectl apply -f "$SCRIPT_DIR/php.secret.yaml"
kubectl apply -f "$SCRIPT_DIR/deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/service.yaml"

HOST_IP=$(ip route | awk '/default/ { print $3 }')
if [ -z "$HOST_IP" ]; then
  echo "Could not determine host IP"
  exit 1
fi
kubectl set env deployment/php MARIADB_HOST=$HOST_IP
