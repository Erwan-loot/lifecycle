#!/bin/bash

# API Uptime-Kuma
UPTIME_KUMA_API="${UPTIME_KUMA_API}"
USERNAME="${USERNAME}"
PASSWORD="${PASSWORD}"
# Token for the API Uptime-Kuma

get_token() {
  curl -X 'POST' \
    "${UPTIME_KUMA_API}/login/access-token" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "grant_type=&username=${USERNAME}&password=${PASSWORD}&scope=&client_id=&client_secret=" \
    --silent | jq -r .access_token
}
API_TOKEN=$(get_token)
disable_probe() {
  local monitor_id=$1
  curl -X POST "${UPTIME_KUMA_API}/api/monitor/${monitor_id}/disable" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"disable\":true}"
}

get_monitors() {
  curl -s -X GET "${UPTIME_KUMA_API}/api/monitors" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "accept: application/json"
}

get_monitor_id_by_container_name() {
  local container_name=$1
  get_monitors | jq -r --arg container_name "$container_name" '.monitors[] | select(.name==$container_name) | .id'
}

docker events --filter event=stop --filter event=die --format "{{.Actor.Attributes.name}}" | while read container_name; do
  monitor_id=$(get_monitor_id_by_container_name "$container_name")
  if [ -n "$monitor_id" ]; then
    disable_probe "$monitor_id"
  fi
done
