# MQTT Broker Proof-of-Concept with Let's Encrypt Certificates

## Table of Contents

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Setup](#setup)
  - [Obtaining Certificates with Certbot](#obtaining-certificates-with-certbot)
  - [Running the MQTT Broker](#running-the-mqtt-broker)
- [Certificate Details](#certificate-details)
- [Notes](#notes)

## Introduction

This repository provides a proof-of-concept for configuring an MQTT broker with TLS encryption using Let's Encrypt certificates. This approach offers several advantages over traditional methods:

- **No Public Exposure:** The server itself does not need to be exposed to the internet; only the domain name must resolve correctly in DNS. This minimizes the attack surface.
- **Ease of Use:** Leveraging Certbot and automated task runners like Just simplifies the certificate issuance process.
- **Cost-Effective:** Let's Encrypt offers free certificates, reducing operational expenses.

Overall, this approach strikes a balance between security and convenience, making it particularly well-suited for private, development and proof-of-concept environments.

## Requirements

- **Domain Name:** A valid domain name (e.g., `mqtt.example.com`).
- **Certbot:** A tool to obtain Let's Encrypt certificates.
- **Just:** A command runner to streamline tasks (see the [Justfile](./Justfile) for commands).
- **Mosquitto:** The MQTT broker software.

## Setup

### Obtaining Certificates with Certbot

Let's Encrypt provides free, automated TLS certificates. However, as it does not support client certificates, only the server certificate is generated.

There are two common methods to validate domain ownership:

- **HTTP-01 Challenge:** Requires a running web server.
- **DNS-01 Challenge:** Involves adding a TXT record to your DNS server, which is useful if you lack a public IP or web server.

> **Note:** Ensure that the certificate's Distinguished Name (DN) exactly matches the hostname clients use to connect, and that the hostname resolves properly in DNS.

#### Installation

First, create a virtual environment and install Certbot:

```bash
uv venv
uv pip install certbot
```

#### Requesting a Certificate

Use the following command syntax to request a certificate:

```bash
just certbot certonly -m <email> --preferred-challenges dns-01 --manual -d <domain1>,<domain2>,...
```

For example:

```bash
just certbot certonly -m oriol@joor.net --preferred-challenges dns-01 --manual -d mqtt.joor.net,pki.joor.net
```

After a successful run, the certificates will be placed in:

```
certbot/config/live/<domain>
```

The directory will contain:

- **`privkey.pem`**: Your private key.
- **`fullchain.pem`**: The certificate chain used by most server software.
- **`chain.pem`**: Intermediate CA certificates (useful for OCSP stapling in Nginx >=1.3.7).
- **`cert.pem`**: A certificate file that may cause issues in some setups and is generally not recommended.

For Mosquitto, only `fullchain.pem` and `privkey.pem` are needed.

### Running the MQTT Broker

To launch the Mosquitto broker with the provided configuration, run:

```bash
just mqtt
```

This command starts Mosquitto with the `mosquitto.conf` file, which is preconfigured to reference the Let's Encrypt certificates.

## Certificate Issuance Without Public Exposure

One major advantage of this certificate issuance method is that the server itself does not need to be exposed to the internet. Only the domain name needs to resolve correctly in DNS. For example, in the accompanying video demonstration, the Mosquitto broker is launched within a WSL2 environment on Windows 11, meaning the MQTT service remains confined to the host machine and is not publicly accessible. The critical requirement is that the hostname matches the DNS entry, ensuring proper certificate issuance without compromising network security.

## Certificate Details

- **Private Key (`privkey.pem`):** Secures your server's identity.
- **Full Chain (`fullchain.pem`):** Contains your server certificate along with necessary intermediate certificates.

Clients typically trust the Let's Encrypt CA certificates provided by their operating system, so there is no need to provide a CA certificate with the broker.

## Certificate Renewal

Let's Encrypt certificates have a limited lifespan (typically 90 days), which means they must be renewed periodically to ensure continuous secure operations. Here’s how you can renew your certificates:

```bash
just certbot renew
## or
just certbot_renew
```

Remember to update your Mosquitto configuration if necessary, though typically the file paths remain the same and the broker will automatically use the new certificate upon restart or reload.

## Notes

- This setup is intended as a proof-of-concept. For production use, consider automating certificate renewals and reviewing additional security measures.
- Update your DNS records accordingly to ensure domain validation succeeds.
- Modify configuration files only if you understand the security implications.

Happy securing!
