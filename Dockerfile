FROM alpine:latest

RUN apk add --no-cache bash curl bind-tools jq cronie

WORKDIR /app
COPY update_netcup.sh /app/update_netcup.sh
COPY .env /app/.env
RUN chmod +x /app/update_netcup.sh

# Cronjob einrichten: alle 30 Minuten
RUN echo "*/30 * * * * /app/update_netcup.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

CMD ["crond", "-f", "-L", "/var/log/cron.log"]
