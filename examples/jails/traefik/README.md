## Traefik

If you want to block IPs that have HTTP Basic Authentication failures on [Traefik](https://traefik.io/), and ban them with iptables, read the instructions below.

First you have to configure your Traefik instance to write the [access logs](https://docs.traefik.io/v1.7/configuration/logs/#access-logs) into a log file on host and specifiy users for [Basic Authentication](https://docs.traefik.io/v1.7/configuration/entrypoints/#basic-authentication). You can use the following compose as a quick example:

```yml
version: "3.2"

services:
traefik:
  image: traefik:1.7-alpine
  command:
    - "--loglevel=INFO"
    - "--accesslog"
    - "--accessLog.filePath=/var/log/access.log"
    - "--accessLog.filters.statusCodes=400-499"
    - "--defaultentrypoints=http,https"
    - "--entryPoints=Name:http Address::80"
    - "--entryPoints=Name:https Address::443 TLS"
    - "--docker.domain=example.com"
    - "--docker.watch"
    - "--docker.exposedbydefault=false"
    - "--api"
    - "--api.dashboard"
  ports:
    - target: 80
      published: 80
      protocol: tcp
    - target: 443
      published: 443
      protocol: tcp
  labels:
    - "traefik.enable=true"
    - "traefik.port=8080"
    - "traefik.backend=traefik"
    - "traefik.frontend.rule=Host:traefik.example.com"
    - "traefik.frontend.auth.basic.usersFile=/htpasswd"
  volumes:
    - "./htpasswd:/htpasswd"
    - "/var/log/traefik:/var/log"
    - "/var/run/docker.sock:/var/run/docker.sock"
  restart: always
```

Traefik will write logs into `/var/log/access.log` for HTTP status code `400-499` and bind the folder to `/var/log/traefik` on the host.

It will also create a [Basic Authentication](https://docs.traefik.io/configuration/entrypoints/#basic-authentication) mechanism through `/htpasswd` file. You can populate this file with the following command:

```
$ docker pull httpd:2.4-alpine
$ docker run --rm httpd:2.4-alpine htpasswd -nbB <USER> <PASSWORD> >> ./htpasswd
```

## Fail2ban container

* Copy files from [filter.d](filter.d) and [jail.d](jail.d) to `./data` in their respective folders
