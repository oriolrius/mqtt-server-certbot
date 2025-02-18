mqtt:
  mosquitto -c mosquitto.conf

certbot +ARGS:
  uv run certbot \
    --config-dir certbot/config \
    --work-dir certbot/work \
    --logs-dir certbot/logs \
    {{ ARGS }}

certbot_get_cert EMAIL DOMAIN:
  just certbot certonly \
    --manual \
    --preferred-challenges dns-01 \
    --agree-tos \
    -m {{ EMAIL }} \
    -d {{ DOMAIN }}

certbot_renew:
  just certbot renew

install_certbot:
  uv venv && uv pip install --reinstall certbot
