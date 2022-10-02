## Traefik

If you want to block IPs that have HTTP Basic Authentication failures on
[Traefik](https://traefik.io/), and ban them with iptables, read the
instructions below.

First you have to configure your Traefik instance to write the [access logs](https://doc.traefik.io/traefik/observability/access-logs/)
into a log file on host and specifiy users for [Basic Authentication](https://doc.traefik.io/traefik/middlewares/http/basicauth/).
You can use the following compose as a quick example:

```yml
services:
  traefik:
    image: traefik:2.8-alpine
    command:
      - "--log"
      - "--log.level=INFO"
      - "--accesslog"
      - "--accesslog.filepath=/var/log/access.log"
      - "--accesslog.filters.statuscodes=400-499"
      - "--entrypoints.http.address=:80"
      - "--entrypoints.https.address=:443"
      - "--entrypoints.https.tls=true"
      - "--providers.docker=true"
      - "--providers.docker.watch"
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
      - "traefik.http.routers.traefik.entrypoints=https"
      - "traefik.http.routers.traefik.rule=Host(`traefik.example.com`)"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.middlewares=traefik-auth"
      - "traefik.http.routers.traefik.tls=true"
      - "traefik.http.middlewares.traefik-auth.basicauth.usersfile=/htpasswd"
    volumes:
      - "./htpasswd:/htpasswd"
      - "/var/log/traefik:/var/log"
      - "/var/run/docker.sock:/var/run/docker.sock"
    restart: always
```

Traefik will write logs into `/var/log/access.log` for HTTP status code
`400-499` and bind the folder to `/var/log/traefik` on the host.

It will also create a [Basic Authentication](https://doc.traefik.io/traefik/middlewares/http/basicauth/)
mechanism through `/htpasswd` file. You can populate this file with the
following command:

```console
$ docker pull httpd:2.4-alpine
$ docker run --rm httpd:2.4-alpine htpasswd -nbB <USER> <PASSWORD> >> ./htpasswd
```

## Fail2ban container

* Copy files from [filter.d](filter.d) and [jail.d](jail.d) to `./data` in
* their respective folders
