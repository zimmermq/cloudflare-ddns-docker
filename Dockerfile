FROM debian:stable-slim

LABEL maintainer="officialEmmel"
LABEL version="1.0"
LABEL description="Cloudflare DDNS Updater"
LABEL repository="https://github.com/officialEmmel/cf-ddns-updater"

RUN apt-get update
RUN apt-get install -y curl cron


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY cloudflare-ddns.sh /usr/local/bin/cloudflare-ddns.sh
RUN chmod +x /usr/local/bin/cloudflare-ddns.sh

CMD ["/bin/bash","/entrypoint.sh"]
