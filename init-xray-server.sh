#!/bin/sh

SS_METHOD="chacha20-ietf-poly1305"
SS_PASSWORD=$(uuidgen)
CONFIG_FILE="/app/xconfig.json"
SERVER_ADDRESS=$(curl -s https://api.ipify.org?format=text)
SERVER_PORT=$(jq -r '.inbounds[0].port' "$CONFIG_FILE")
SERVER_NAME="server-$(openssl rand -base64 6 | tr -dc A-Za-z0-9 | head -c 5)"

jq --arg password "$SS_PASSWORD" \
   '.inbounds[0].settings.password = $password' \
   "$CONFIG_FILE" > /tmp/xconfig_tmp.json && mv /tmp/xconfig_tmp.json "$CONFIG_FILE"

ENCODED=$(echo -n "${SS_METHOD}:${SS_PASSWORD}" | base64 -w 0)
CLIENT_LINK="ss://${ENCODED}@${SERVER_ADDRESS}:${SERVER_PORT}#${SERVER_NAME}"

echo "$CLIENT_LINK" | tee /app/client-ss-url.txt
qrencode -s 10 -o /app/client-ss-qr.png "$CLIENT_LINK"
qrencode -t UTF8 "$CLIENT_LINK"
