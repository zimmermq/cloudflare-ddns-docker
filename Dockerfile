FROM alpine:3.7

LABEL maintainer="zimmermq"
LABEL version="1.0"
LABEL description="Cloudflare DDNS Updater"
LABEL repository="https://github.com/zimmermq/cloudflare-ddns-docker"

RUN apk update
RUN apk add bash
RUN apk add curl

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY cloudflare-templatev4.sh /usr/local/bin/cloudflare-templatev4.sh.sh
RUN chmod +x /usr/local/bin/cloudflare-templatev4.sh.sh

CMD ["/bin/bash","/entrypoint.sh"]
