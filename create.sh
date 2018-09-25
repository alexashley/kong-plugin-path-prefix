#!/usr/bin/env bash

set -eu

KONG_ADMIN_URL=http://localhost:8001

service_id=$(curl -s -X POST ${KONG_ADMIN_URL}/services -d name=mockbin -d url="https://mockbin.org/request" | jq -r '.id')

curl -s -X POST ${KONG_ADMIN_URL}/plugins -d name=path-prefix -d config.path_prefix=/mock -d service_id=${service_id}

curl -s -X POST ${KONG_ADMIN_URL}/routes -d paths[]=/mock -d strip_path=false -d service.id=${service_id}
curl -s -X POST ${KONG_ADMIN_URL}/routes -d paths[]=/mock/version -d strip_path=false -d service.id=${service_id}
curl -s -X POST ${KONG_ADMIN_URL}/routes -d paths[]=/mock/healthz -d strip_path=false -d service.id=${service_id}