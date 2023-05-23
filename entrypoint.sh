#!/bin/sh

# install cron job 
cronjob="${CRON_JOB:-0 * * * *}"
cronjob_log="${CRON_JOB_LOG:-/var/log/cron.log}"

echo "$cronjob /usr/local/bin/cloudflare-ddns.sh >> $cronjob_log 2>&1" > /etc/cron.d/cloudflare-ddns

chmod 0644 /etc/cron.d/cloudflare-ddns

crontab /etc/cron.d/cloudflare-ddns

touch $cronjob_log

# start cron
cron -f
