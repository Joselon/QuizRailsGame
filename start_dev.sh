#!/bin/bash

PORT=3000

echo "Iniciando Cloudflared en segundo plano..."
cloudflared tunnel --url http://localhost:$PORT > log/cloudflared.log 2>&1 &

for i in {1..10}; do
  TUNNEL_URL=$(grep -oE 'https://[a-z0-9\-]+\.trycloudflare\.com' log/cloudflared.log | head -n 1 | sed 's|https://||')
  if [ -n "$TUNNEL_URL" ]; then
    echo "URL pública: $TUNNEL_URL"
    break
  fi
  sleep 1
done

if [ -z "$TUNNEL_URL" ]; then
  echo "No se pudo obtener la URL del túnel"
  exit 1
fi

export TUNNEL_URL

echo "Iniciando servidor Rails..."

rails server -b 0.0.0.0 -p $PORT
