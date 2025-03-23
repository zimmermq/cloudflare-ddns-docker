# ☁️ Cloudflare DDNS IP Updater

[![Docker Pulls](https://img.shields.io/docker/pulls/zimmermq/cloudflare-ddns.svg)](https://hub.docker.com/r/zimmermq/cloudflare-ddns)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/K0p1-Git/cloudflare-ddns-updater/blob/main/LICENSE)

A lightweight Docker container that automatically updates your Cloudflare DNS records with your current IP address, allowing remote access to your home network via a custom domain name without a static IP.

## Features

- Lightweight Alpine-based Docker image
- Pure Bash implementation for minimal overhead
- Scheduled updates via cron
- Multiple notification options (Slack, Discord, Ntfy, Telegram)
- Simple configuration via environment variables

## Quick Start

```bash
docker pull zimmermq/cloudflare-ddns
```

### Docker Compose Setup

```yaml
services:
  ddns:
    image: zimmermq/cloudflare-ddns
    restart: always
    container_name: ddns
    environment:
      - CRON_JOB=*/15 * * * *      # Check every 15 minutes
      - AUTH_EMAIL=mail@example.com
      - AUTH_METHOD=global
      - AUTH_KEY=abcdefgh12345
      - ZONE_IDENTIFIER=123456abcdefgh
      - RECORD_NAME=example.com
      - RECORD_TYPE=A
      - TTL=3600
      - PROXY=true
      - SITENAME=example.com
      - NOTIFICATION_LEVEL=on_success_or_error
      - NTFYURI=https://ntfy.example.com/ddns
```

## Configuration Reference

### Required Settings

| Environment Variable | Description |
|---|---|
| `AUTH_EMAIL` | Email address used for your Cloudflare account |
| `AUTH_METHOD` | Authentication method (`global` for Global API Key or `token` for Scoped API Token) |
| `AUTH_KEY` | Your Cloudflare API key or token |
| `ZONE_IDENTIFIER` | Zone ID for your domain (found in Cloudflare Dashboard → Domain → Overview) |
| `RECORD_NAME` | The DNS record to update (e.g., `home.example.com`) |
| `RECORD_TYPE` | DNS record type (typically `A` for IPv4 or `AAAA` for IPv6) |
| `TTL` | Time-to-live for DNS record in seconds (1 = auto, 60-86400 for manual) |
| `PROXY` | Whether to proxy through Cloudflare (`true` or `false`) |
| `CRON_JOB` | Schedule for IP check (e.g., `*/5 * * * *` for every 5 minutes) |

### Getting Your Cloudflare API Credentials

1. Log in to your Cloudflare dashboard
2. Go to "My Profile" → "API Tokens"
3. Create a token with "Zone.DNS" edit permissions for your domain
4. Find your Zone ID in the "Overview" tab of your domain

### Notification Options

Control how and when you receive updates:

| Environment Variable | Description |
|---|---|
| `SITENAME` | Identifier used in notifications (typically your domain name) |
| `NOTIFICATION_LEVEL` | When to send notifications:<br>• `on_error` - Only on failures<br>• `on_success_or_error` - On success or failure<br>• `always` - Every attempt, even when IP hasn't changed |

#### Notification Service Configuration

<details>
<summary>Slack</summary>

| Environment Variable | Description |
|---|---|
| `SLACKURI` | Your Slack webhook URL |
| `SLACKCHANNEL` | The Slack channel to post to |
</details>

<details>
<summary>Discord</summary>

| Environment Variable | Description |
|---|---|
| `DISCORDURI` | Your Discord webhook URL |
</details>

<details>
<summary>Ntfy</summary>

| Environment Variable | Description |
|---|---|
| `NTFYURI` | Your Ntfy URI including topic (e.g., `https://ntfy.example.com/ddns`) |
</details>

<details>
<summary>Telegram</summary>

| Environment Variable | Description |
|---|---|
| `TELEGRAM_TOKEN` | Your Telegram bot token |
| `TELEGRAM_CHAT_ID` | Your Telegram chat ID |
</details>

## Cron Schedule Reference

The `CRON_JOB` variable uses standard cron syntax:

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │
# │ │ │ │ │
# * * * * *
```

Common examples:
- `*/5 * * * *` - Every 5 minutes
- `0 * * * *` - Every hour
- `0 0 * * *` - Once a day at midnight

For help creating cron expressions, visit [crontab.guru](https://crontab.guru).

## Use Cases

- Hosting a personal website or services from home
- Remote access to home lab or self-hosted applications
- NAS or media server access from anywhere
- Home automation remote control
- Game servers accessible via domain name

## Troubleshooting

### Common Issues

1. **No IP Updates**: Check your cron schedule and logs
2. **Authentication Errors**: Verify your Cloudflare API credentials
3. **Missing Notifications**: Confirm notification service credentials and network access

View container logs with:
```bash
docker logs ddns
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

For major changes, please open an issue first to discuss what you would like to change.

## Credits

This project is a fork of [officialEmmel/cloudflare-ddns-updater](https://github.com/officialEmmel/cloudflare-ddns-docker) with Docker support and notification services added.

Original script reference from [Keld Norman](https://www.youtube.com/watch?v=vSIBkH7sxos).

## License

[MIT](https://github.com/K0p1-Git/cloudflare-ddns-updater/blob/main/LICENSE)