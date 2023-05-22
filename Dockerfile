FROM debian:stable-slim

LABEL maintainer="officialEmmel"
LABEL version="1.0"
LABEL description="Cloudflare DDNS Updater"
LABEL repository="https://github.com/officialEmmel/cf-ddns-updater-docker"


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY cloudflare-ddns.sh /usr/local/bin/cloudflare-ddns.sh
RUN chmod +x /usr/local/bin/cloudflare-ddns.sh

CMD ["/entrypoint.sh"]