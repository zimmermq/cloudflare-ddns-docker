#!/bin/bash
set -eo pipefail

# Script: cloudflare-ddns-docker
# Purpose: Update Cloudflare DNS records with current IP address
# Based on work by officialEmmel and K0p1-Git, improved by zimmermq

# Define required environment variables
REQUIRED_VARS=(
  "AUTH_EMAIL"
  "AUTH_METHOD"
  "AUTH_KEY"
  "ZONE_IDENTIFIER"
  "RECORD_NAME"
  "TTL"
  "PROXY"
)

# Check if required variables are set
for VAR in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!VAR}" ]]; then
    echo "Error: ${VAR} is not set"
    exit 1
  fi
done

# Print configuration (hide sensitive info)
echo "=================================="
echo "Cloudflare DDNS Docker Setup"
echo "=================================="
echo "Auth Email: ${AUTH_EMAIL}"
echo "Auth Method: ${AUTH_METHOD}"
echo "Auth Key: ${AUTH_KEY:0:3}****${AUTH_KEY: -3}"
echo "Zone Identifier: ${ZONE_IDENTIFIER}"
echo "Record Name: ${RECORD_NAME}"
echo "TTL: ${TTL}"
echo "Proxy: ${PROXY}"
echo "Cron Schedule: ${CRON_JOB:-0 * * * *}"
echo "=================================="

# Set default cron job if not specified (hourly)
CRON_JOB=${CRON_JOB:-0 * * * *}

# Install cron job
echo ">> Setting up cron job"
CRON_FILE="/usr/local/bin/cloudflare-ddns-cron"
echo "$CRON_JOB /bin/bash /usr/local/bin/cloudflare-templatev4.sh" > "$CRON_FILE"
chmod 0644 "$CRON_FILE"
crontab "$CRON_FILE"

# Export environment variables (excluding proxy settings)
echo ">> Exporting environment variables"
printenv | grep -v "no_proxy" | grep -v "NO_PROXY" >> /etc/environment

# Start the DDNS update process immediately
echo ">> Running initial DDNS update"
if [[ -f /usr/local/bin/cloudflare-templatev4.sh ]]; then
  /bin/bash /usr/local/bin/cloudflare-templatev4.sh
else
  echo "Error: Update script not found at /usr/local/bin/cloudflare-templatev4.sh"
  exit 1
fi

echo ">> Setup complete. Starting cron service... ($(date "+%Y-%m-%d %H:%M:%S"))"
echo "=================================="

# Start cron daemon in foreground with logging
exec crond -f -l 2