<p align="center"><a href="https://github.com/crazy-max/docker-fail2ban" target="_blank"><img height="128"src="https://raw.githubusercontent.com/crazy-max/docker-fail2ban/master/.res/docker-fail2ban.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/crazymax/fail2ban/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/crazy-max/docker-fail2ban?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/crazy-max/docker-fail2ban/actions?workflow=build"><img src="https://github.com/crazy-max/docker-fail2ban/workflows/build/badge.svg" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/fail2ban/"><img src="https://img.shields.io/docker/stars/crazymax/fail2ban.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/fail2ban/"><img src="https://img.shields.io/docker/pulls/crazymax/fail2ban.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://www.codacy.com/app/crazy-max/docker-fail2ban"><img src="https://img.shields.io/codacy/grade/10a198e9cd7948a6a2d71d9ca10548d1.svg?style=flat-square" alt="Code Quality"></a>
  <br /><a href="https://www.patreon.com/crazymax"><img src="https://img.shields.io/badge/donate-patreon-f96854.svg?logo=patreon&style=flat-square" alt="Support me on Patreon"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [Fail2ban](https://www.fail2ban.org) Docker image based on Alpine Linux.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other 🐳 Docker images!

💡 Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun) project!

## Docker

### Multi-platform image

Following platforms for this image are available:

```
$ docker run --rm mplatform/mquery crazymax/fail2ban:latest
Image: crazymax/fail2ban:latest
 * Manifest List: Yes
 * Supported platforms:
   - linux/amd64
   - linux/arm/v6
   - linux/arm/v7
   - linux/arm64
   - linux/386
   - linux/ppc64le
   - linux/s390x
```

### Environment variables

* `TZ`: The timezone assigned to the container (default `UTC`)
* `F2B_LOG_TARGET`: Set the log target. This could be a file, SYSLOG, STDERR or STDOUT (default `STDOUT`)
* `F2B_LOG_LEVEL`: Log level output (default `INFO`)
* `F2B_DB_PURGE_AGE`: Age at which bans should be purged from the database (default `1d`)
* `F2B_BACKEND`: Specifies the backend used to get files modification (default `auto`)
* `F2B_MAX_RETRY`: Number of failures before a host get banned (default `5`)
* `F2B_DEST_EMAIL`: Destination email address used solely for the interpolations in configuration files (default `root@localhost`)
* `F2B_SENDER`: Sender email address used solely for some actions (default `root@$(hostname -f)`)
* `F2B_ACTION`: Default action on ban (default `%(action_)s`)
* `F2B_IPTABLES_CHAIN`: Specifies the iptables chain to which the Fail2Ban rules should be added (default `DOCKER-USER`)
* `SSMTP_HOST`: SMTP server host
* `SSMTP_PORT`: SMTP server port (default `25`)
* `SSMTP_HOSTNAME`: Full hostname (default `$(hostname -f)`)
* `SSMTP_USER`: SMTP username
* `SSMTP_PASSWORD`: SMTP password
* `SSMTP_TLS`: SSL/TLS (default `NO`)

> :warning: If you want email to be sent after a ban, you have to configure SSMTP env vars and set F2B_ACTION to `%(action_mw)s` or `%(action_mwl)s`

### Volumes

* `/data`: Contains customs jails, actions and filters and Fail2ban persistent database

## Use this image

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of folder [examples/compose](examples/compose) in `/var/fail2ban/` on your host for example. Edit the compose and env files with your preferences and run the following commands :

```
docker-compose up -d
docker-compose logs -f
```

### Command line

You can also use the following minimal command :

```
docker run -d --name fail2ban --restart always \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  -v $(pwd)/data:/data \
  -v /var/log:/var/log:ro \
  crazymax/fail2ban:latest
```

## Notes

### `DOCKER-USER` chain

In Docker 17.06 and higher through [docker/libnetwork#1675](https://github.com/docker/libnetwork/pull/1675), you can add rules to a new table called `DOCKER-USER`, and these rules will be loaded before any rules Docker creates automatically. This is useful to make `iptables` rules created by Fail2Ban persistent.

If you have an older version of Docker, you may just change `F2B_IPTABLES_CHAIN` to `FORWARD`. This way, all Fail2Ban rules come before any Docker rules but these rules will now apply to ALL forwarded traffic.

More info : https://docs.docker.com/network/iptables/

### `DOCKER-USER` and `INPUT` chains

If your Fail2Ban container is attached to `DOCKER-USER` chain instead of `INPUT`, the rules will be applied **only to containers**. This means that any packets coming into the `INPUT` chain will bypass these rules that now reside under the `FORWARD` chain.

This implies that [sshd](examples/jails/sshd) jail for example will not work as intended. You can create another Fail2Ban container. Take a look at [this example](examples/compose-multi).

### Use fail2ban-client

[Fail2ban commands](http://www.fail2ban.org/wiki/index.php/Commands) can be used through the container. Here is an example if you want to ban an IP manually :

```
docker exec -t <CONTAINER> fail2ban-client set <JAIL> banip <IP>
```

### Custom jails, actions and filters

Custom jails, actions and filters can be added respectively in `/data/jail.d`, `/data/action.d` and `/data/filter.d`. If you add an action/filter that already exists, it will be overriden.

> :warning: Container has to be restarted to propagate changes

### Override `jail.local` configuration

You can also override the `jail.local` configuration generated by this image if you want by creating a configuration file `/data/jail.d/00-jail.local`.

FYI, here is the order *jail* configuration would be loaded:

```
jail.conf
jail.d/*.conf (in alphabetical order)
jail.local
jail.d/*.local (in alphabetical order)
```

### Jail examples

Jail examples can be found in [examples/jails](examples/jails) to work with this image.

## How can I help ?

All kinds of contributions are welcome :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
But we're not gonna lie to each other, I'd rather you buy me a beer or two :beers:!

[![Support me on Patreon](.res/patreon.png)](https://www.patreon.com/crazymax) 
[![Paypal Donate](.res/paypal.png)](https://www.paypal.me/crazyws)

## License

MIT. See `LICENSE` for more details.<br />
