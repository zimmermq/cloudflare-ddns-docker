#!/bin/bash

#check if vars aure set
if [[ -z "${AUTH_EMAIL}" ]]; then
  echo "AUTH_EMAIL is not set"
  exit 1
fi
if [[ -z "${AUTH_METHOD}" ]]; then
  echo "AUTH_METHOD is not set"
  exit 1
fi
if [[ -z "${AUTH_KEY}" ]]; then
  echo "AUTH_KEY is not set"
  exit 1
fi
if [[ -z "${ZONE_IDENTIFIER}" ]]; then
  echo "ZONE_IDENTIFIER is not set"
  exit 1
fi
if [[ -z "${RECORD_NAME}" ]]; then
  echo "RECORD_NAME is not set"
  exit 1
fi
if [[ -z "${TTL}" ]]; then
  echo "TTL is not set"
  exit 1
fi
if [[ -z "${PROXY}" ]]; then
  echo "PROXY is not set"
  exit 1
fi

echo "=================================="
echo "cloudflare-ddns-docker by officialEmmel based on script by K0p1-Git"
echo "=================================="
echo "Auth Email: ${AUTH_EMAIL}"
echo "Auth Method: ${AUTH_METHOD}"
echo "Auth Key: ***"
echo "Zone Identifier: ${ZONE_IDENTIFIER}"
echo "Record Name: ${RECORD_NAME}"
echo "TTL: ${TTL}"
echo "Proxy: ${PROXY}"
echo "Crond Job: ${CRON_JOB:-0 * * * *}"
echo "=================================="

# install cron job 
echo ">> installing cron job"
cronjob="${CRON_JOB:-0 * * * *}"
cronjob_log="${CRON_JOB_LOG:-/var/log/cron.log}"

echo "$cronjob /bin/bash /usr/local/bin/cloudflare-ddns.sh" > /usr/local/bin/cloudflare-ddns-cron

chmod 0644 /usr/local/bin/cloudflare-ddns-cron

crontab /usr/local/bin/cloudflare-ddns-cron

echo ">> loading env vars"
printenv | grep -v "no_proxy" >> /etc/environment

echo ">> setup ready. starting cron... ($(date "+%Y-%m-%d %H:%M:%S"))" 
echo "=================================="

# start cron
crond -f -l 2
