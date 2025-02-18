# Proof of Concept for MQTT Broker with Let's Encrypt certificates

## Introduction

## Let's Encrypt certificates

Let's Encrypt is a free, automated, and open Certificate Authority. That doesn't allow to create client certificates. So, only the server certificate is created.

### Requirements for this scenario

- A domain name

#### Getting certificates with certbot

##### Install certbot

```bash
uv venv
uv pip install certbot
```

##### Get certificates

There are several methods to validate domain ownership. The most common is the `http-01` challenge, which requires a running web server.

Alternatively, the `dns-01` challenge involves adding a TXT record to your DNS server. This approach doesn’t require a web server or a public IP address.

Additionally, the certificate’s Distinguished Name (DN) must match the hostname clients use to connect, and this hostname must be resolvable via public or private DNS.

Command syntax for getting certificates:

```bash
just certbot certonly -m <email> --preferred-challenges dns-01 --manual -d <domain1>,<domain2>,...
```

Sample:

```bash
just certbot certonly -m oriol@joor.net --preferred-challenges dns-01 --manual -d mqtt.joor.net,pki.joor.net
```

After that in the folder `certbot/config/live/<domain>` there are the certificates.

- `privkey.pem`  : the private key for your certificate.
- `fullchain.pem`: the certificate file used in most server software.
- `chain.pem`    : used for OCSP stapling in Nginx >=1.3.7.
- `cert.pem`     : will break many server configurations, and should not be used without reading further documentation (see link below).

For configuring a Mosquitto broker, the `fullchain.pem` and `privkey.pem` are needed. The CA certificate is not needed because the clients will use the Let's Encrypt CA certificate available in the operating system.
