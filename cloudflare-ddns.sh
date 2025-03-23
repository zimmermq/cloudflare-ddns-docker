#!/bin/bash

# the cf ddns script by K0p1-Git modified with some notification options and dockerized by me

# Load environment variables with sensible defaults
auth_email="${AUTH_EMAIL:-}"
auth_method="${AUTH_METHOD:-token}"
auth_key="${AUTH_KEY:-}"
zone_identifier="${ZONE_IDENTIFIER:-}"
record_name="${RECORD_NAME:-}"
ttl="${TTL:-3600}"
proxy="${PROXY:-false}"

sitename="${SITENAME:-}"
notification_level="${NOTIFICATION_LEVEL:-on_error}"
slackuri="${SLACKURI:-}"
slackchannel="${SLACKCHANNEL:-}"
discorduri="${DISCORDURI:-}"
ntfyuri="${NTFYURI:-}"
telegram_token="${TELEGRAM_TOKEN:-}"
telegram_chat_id="${TELEGRAM_CHAT_ID:-}"

# Define logging functions
log() {
  echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') $1"
}

err() {
  echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
}

send_notification() {
  local message="$1"

  if [[ -n $slackuri ]]; then
    log "Sending notification to slack"
    curl --silent -o /dev/null -L -X POST "$slackuri" \
    --data-raw "{
      \"channel\": \"$slackchannel\",
      \"text\": \"$message\"
    }" || log "Failed to send Slack notification"
  fi

  if [[ -n $discorduri ]]; then
    log "Sending notification to discord"
    curl --silent -o /dev/null -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST \
    --data-raw "{
      \"content\": \"$message\"
    }" "$discorduri" || log "Failed to send Discord notification"
  fi

  if [[ -n $ntfyuri ]]; then
    log "Sending notification to ntfy"
    curl --silent -o /dev/null -d "$message" "$ntfyuri" || log "Failed to send ntfy notification"
  fi

  if [[ -n $telegram_token ]] && [[ -n $telegram_chat_id ]]; then
    log "Sending notification to telegram"
    curl --silent -o /dev/null -H 'Content-Type: application/json' -X POST \
    --data-raw "{
      \"chat_id\": \"$telegram_chat_id\",
      \"text\": \"$message\"
    }" "https://api.telegram.org/bot$telegram_token/sendMessage" || log "Failed to send Telegram notification"
  fi
}

notify() {
  local level="$1"
  local message="$2"

  if [[ $notification_level == "always" ]]; then
    send_notification "$message"
  elif [[ $notification_level == "on_success_or_error" ]] && [[ "$level" == "success" || "$level" == "error" ]]; then
    send_notification "$message"
  elif [[ $notification_level == "on_error" ]] && [[ "$level" == "error" ]]; then
    send_notification "$message"
  fi
}

# Validate required parameters
if [[ -z "$auth_email" || -z "$auth_key" || -z "$zone_identifier" || -z "$record_name" ]]; then
  err "Missing required parameters. Please ensure AUTH_EMAIL, AUTH_KEY, ZONE_IDENTIFIER, and RECORD_NAME are set."
  exit 1
fi

# IPv4 regex
ipv4_regex='([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])'

# Get current public IP
log "Obtaining current public IP address"
ip=$(curl -s -4 https://cloudflare.com/cdn-cgi/trace | grep -E '^ip' | sed -E "s/^ip=($ipv4_regex)$/\1/")
if [[ ! $? -eq 0 ]] || [[ ! $ip =~ ^$ipv4_regex$ ]]; then
  # Try alternative IP services
  log "Failed to get IP from Cloudflare, trying alternatives"
  ip=$(curl -s https://api.ipify.org || curl -s https://ipv4.icanhazip.com)

  # Validate IP format again
  if [[ ! $ip =~ ^$ipv4_regex$ ]]; then
    err "Failed to find valid IP"
    notify "error" "DDNS Update Failed: Failed to find valid IP"
    exit 2
  fi
fi

log "Current public IP: $ip"

# Set proper auth header based on authentication method
if [[ "$auth_method" == "global" ]]; then
  auth_header="X-Auth-Key:"
else
  auth_header="Authorization: Bearer"
fi

# Get current DNS record
log "Getting current DNS record for $record_name"
response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name" \
                      -H "X-Auth-Email: $auth_email" \
                      -H "$auth_header $auth_key" \
                      -H "Content-Type: application/json")

if [[ $? -ne 0 ]]; then
  err "Failed to communicate with Cloudflare API"
  notify "error" "DDNS Update Failed: Cannot connect to Cloudflare API"
  exit 1
fi

# Check if record exists
if [[ $response == *"\"count\":0"* ]]; then
  err "Record does not exist, perhaps create one first? (${ip} for ${record_name})"
  notify "error" "DDNS Update Failed: Record does not exist for ${record_name}"
  exit 1
fi

# Get existing IP
old_ip=$(echo "$response" | sed -E 's/.*"content":"(([0-9]{1,3}\.){3}[0-9]{1,3})".*/\1/')

# Check if extracted IP is valid
if [[ ! $old_ip =~ ^$ipv4_regex$ ]]; then
  err "Failed to extract current IP from API response"
  notify "error" "DDNS Update Failed: Could not determine current IP for ${record_name}"
  exit 1
fi

# Compare IPs and update if necessary
if [[ "$ip" == "$old_ip" ]]; then
  log "Update skipped because IP ($ip) for ${record_name} has not changed."
  notify "debug" "DDNS-Update Skipped: IP ($ip) for ${record_name} has not changed."
  exit 0
fi

# Get record identifier
record_identifier=$(echo "$response" | sed -E 's/.*"id":"([^"]+)".*/\1/')
if [[ -z "$record_identifier" ]]; then
  err "Failed to extract record identifier"
  notify "error" "DDNS Update Failed: Could not determine record identifier for ${record_name}"
  exit 1
fi

# Update DNS record
log "Updating DNS record for $record_name to $ip"
update=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                     -H "X-Auth-Email: $auth_email" \
                     -H "$auth_header $auth_key" \
                     -H "Content-Type: application/json" \
                     --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":$ttl,\"proxied\":$proxy}")

if [[ $? -ne 0 ]]; then
  err "Failed to communicate with Cloudflare API during update"
  notify "error" "DDNS Update Failed: Cannot connect to Cloudflare API during update"
  exit 1
fi

# Report status
if [[ "$update" == *"\"success\":false"* ]]; then
  err "DDNS update failed for $record_name ($ip). DUMPING RESULTS:\n$update"
  notify "error" "${sitename:+$sitename }DDNS Update Failed: $record_name: $record_identifier ($ip)"
  exit 1
else
  log "DDNS updated for $record_name to $ip"
  notify "success" "${sitename:+$sitename }Updated: $record_name's new IP Address is $ip"
  exit 0
fi