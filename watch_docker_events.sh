#!/bin/bash

# API Uptime-Kuma
UPTIME_KUMA_API="${UPTIME_KUMA_API}"

# Token for the API Uptime-Kuma
API_TOKEN="${API_TOKEN}"

# Function to disable probe
disable_probe() {
  local container_name=$1
  curl -X POST "${UPTIME_KUMA_API}/disable-monitor" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"${container_name}\"}"
}

# Watch the event docker and stop the container
docker events --filter event=stop --filter event=die --format "{{.Actor.Attributes.name}}" | while read container_name; do
  disable_probe "$container_name"
done
