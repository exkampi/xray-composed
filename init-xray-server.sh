#!/bin/sh

_x25519=$(xray x25519)
PRIVATE_KEY=$(echo "$_x25519" | awk -F': ' '/Private key/{print $2}')
PUBLIC_KEY=$(echo "$_x25519" | awk -F': ' '/Public key/{print $2}')
CLIENT_UUID=$(uuidgen)
SHORT_ID=$(openssl rand -hex 8)
CONFIG_FILE="/app/xconfig.json"
SNI=$(jq -r '.inbounds[0].streamSettings.realitySettings.serverNames[0]' "$CONFIG_FILE")
FINGERPRINT=$(jq -r '.inbounds[0].streamSettings.realitySettings.fingerprint' "$CONFIG_FILE")
FLOW=$(jq -r '.inbounds[0].settings.clients[0].flow' "$CONFIG_FILE")
SERVER_ADDRESS=$(curl -s https://api.ipify.org?format=text)
SECURITY=$(jq -r '.inbounds[0].streamSettings.security' "$CONFIG_FILE")
NETWORK=$(jq -r '.inbounds[0].streamSettings.network' "$CONFIG_FILE")

jq --arg uuid "$CLIENT_UUID" \
   --arg private_key "$PRIVATE_KEY" \
   --arg short_id "$SHORT_ID" \
   '.inbounds[0].settings.clients[0].id = $uuid |
    .inbounds[0].streamSettings.realitySettings.privateKey = $private_key |
    .inbounds[0].streamSettings.realitySettings.shortIds = [$short_id]' \
   "$CONFIG_FILE" > /tmp/xconfig_tmp.json && mv /tmp/xconfig_tmp.json "$CONFIG_FILE"

CLIENT_LINK="vless://${CLIENT_UUID}@${SERVER_ADDRESS}:443?security=${SECURITY}&type=${NETWORK}&sni=${SNI}&fp=${FINGERPRINT}&pbk=${PUBLIC_KEY}&flow=${FLOW}&sid=${SHORT_ID}#xray-server"

echo "$CLIENT_LINK" | tee /app/client-vless-url.txt
qrencode -s 10 -o /app/client-vless-qr.png "$CLIENT_LINK"
qrencode -t UTF8 "$CLIENT_LINK"
