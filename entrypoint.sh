#!/bin/bash

echo "cloudflare-ddns-updater dockerized"
echo "installing cronjob based on user-conf"

# install cron job 
cronjob="${CRON_JOB:-0 * * * *}"
cronjob_log="${CRON_JOB_LOG:-/var/log/cron.log}"

echo "$cronjob /bin/bash /usr/local/bin/cloudflare-ddns.sh" > /cloudflare-ddns

chmod 0644 /cloudflare-ddns

crontab /cloudflare-ddns

#touch $cronjob_log

echo "loading env vars"
printenv | grep -v "no_proxy" >> /etc/environment

echo "starting cron..."

# start cron
crond -f -l 2
