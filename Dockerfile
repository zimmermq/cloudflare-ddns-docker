FROM alpine:3.7

LABEL maintainer="zimmermq" \
      version="1.0" \
      description="Cloudflare DDNS Updater" \
      repository="https://github.com/zimmermq/cloudflare-ddns-docker"

RUN apk update && \
    apk add --no-cache bash curl

COPY entrypoint.sh /entrypoint.sh
COPY cloudflare-templatev4.sh /usr/local/bin/cloudflare-templatev4.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/cloudflare-templatev4.sh

CMD ["/bin/bash", "/entrypoint.sh"]