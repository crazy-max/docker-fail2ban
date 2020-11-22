<p align="center"><a href="https://github.com/crazy-max/docker-fail2ban" target="_blank"><img height="128" src="https://raw.githubusercontent.com/crazy-max/docker-fail2ban/master/.github/docker-fail2ban.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/crazymax/fail2ban/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/crazy-max/docker-fail2ban?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/crazy-max/docker-fail2ban/actions?workflow=build"><img src="https://img.shields.io/github/workflow/status/crazy-max/docker-fail2ban/build?label=build&logo=github&style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/fail2ban/"><img src="https://img.shields.io/docker/stars/crazymax/fail2ban.svg?style=flat-square&logo=docker" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/fail2ban/"><img src="https://img.shields.io/docker/pulls/crazymax/fail2ban.svg?style=flat-square&logo=docker" alt="Docker Pulls"></a>
  <br /><a href="https://github.com/sponsors/crazy-max"><img src="https://img.shields.io/badge/sponsor-crazy--max-181717.svg?logo=github&style=flat-square" alt="Become a sponsor"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

[Fail2ban](https://www.fail2ban.org) Docker image based on Alpine Linux.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other Docker images!

💡 Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun) project!

___

* [Docker](#docker)
  * [Image](#image)
  * [Environment variables](#environment-variables)
  * [Volumes](#volumes)
* [Usage](#usage)
  * [Docker Compose](#docker-compose)
  * [Command line](#command-line)
* [Upgrade](#upgrade)
* [Notes](#notes)
  * [`DOCKER-USER` chain](#docker-user-chain)
  * [`DOCKER-USER` and `INPUT` chains](#docker-user-and-input-chains)
  * [Jails examples](#jails-examples)
  * [Use iptables tooling without nftables backend](#use-iptables-tooling-without-nftables-backend)
  * [Use fail2ban-client](#use-fail2ban-client)
  * [Global jail configuration](#global-jail-configuration)
  * [Custom jails, actions and filters](#custom-jails-actions-and-filters)
* [How can I help?](#how-can-i-help)
* [License](#license)

## Docker

### Image

| Registry                                                                                         | Image                           |
|--------------------------------------------------------------------------------------------------|---------------------------------|
| [Docker Hub](https://hub.docker.com/r/crazymax/fail2ban/)                                            | `crazymax/fail2ban`                 |
| [GitHub Container Registry](https://github.com/users/crazy-max/packages/container/package/fail2ban)  | `ghcr.io/crazy-max/fail2ban`        |

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
* `SSMTP_HOST`: SMTP server host
* `SSMTP_PORT`: SMTP server port (default `25`)
* `SSMTP_HOSTNAME`: Full hostname (default `$(hostname -f)`)
* `SSMTP_USER`: SMTP username
* `SSMTP_PASSWORD`: SMTP password
* `SSMTP_TLS`: Use TLS to talk to the SMTP server (default `NO`)
* `SSMTP_STARTTLS`: Specifies whether ssmtp does a EHLO/STARTTLS before starting SSL negotiation (default `NO`)

> 💡 `SSMTP_PASSWORD_FILE` can be used to fill in the value from a file, especially for Docker's secrets feature.

### Volumes

* `/data`: Contains customs jails, actions and filters and Fail2ban persistent database

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of folder
[examples/compose](examples/compose) in `/var/fail2ban/` on your host for example. Edit the compose and env files
with your preferences and run the following commands:

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

## Upgrade

Recreate the container whenever I push an update:

```bash
docker-compose pull
docker-compose up -d
```

## Notes

### `DOCKER-USER` chain

In Docker 17.06 and higher through [docker/libnetwork#1675](https://github.com/docker/libnetwork/pull/1675),
you can add rules to a new table called `DOCKER-USER`, and these rules will be loaded before any rules Docker creates
automatically. This is useful to make `iptables` rules created by Fail2Ban persistent.

If you have an older version of Docker, you may just change the chain definition for your jail to `chain = FORWARD`.
This way, all Fail2Ban rules come before any Docker rules but these rules will now apply to ALL forwarded traffic.

More info : https://docs.docker.com/network/iptables/

### `DOCKER-USER` and `INPUT` chains

If your Fail2Ban container is attached to `DOCKER-USER` chain instead of `INPUT`, the rules will be applied
**only to containers**. This means that any packets coming into the `INPUT` chain will bypass these rules that now
reside under the `FORWARD` chain.

This is why the [sshd](examples/jails/sshd) jail contains a [`chain = INPUT`](examples/jails/sshd/jail.d/sshd.conf)
in its definition and [traefik](examples/jails/traefik) jail contains
[`chain = DOCKER-USER`](examples/jails/traefik/jail.d/traefik.conf).

### Jails examples

Here are some examples using the `DOCKER-USER` chain:

* [guacamole](examples/jails/guacamole)
* [traefik](examples/jails/traefik)

And others using the `INPUT` chain:

* [proxmox](examples/jails/proxmox)
* [sshd](examples/jails/sshd)

### Use iptables tooling without nftables backend

As you may know, [nftables](https://wiki.nftables.org) is available as a modern replacement for the kernel's iptables
subsystem on Linux. 

This image still uses `iptables` to preserve backwards compatibility but
[an issue is opened](https://github.com/crazy-max/docker-fail2ban/issues/29) about its implementation.

If your system's `iptables` tooling uses the nftables backend, this will throw the error
`stderr: 'iptables: No chain/target/match by that name.'`. You need to switch the `iptables` tooling to 'legacy' mode
to avoid these problems. This is the case on at least Debian 10 (Buster), Ubuntu 19.04, Fedora 29 and newer releases
of these distributions by default. RHEL 8 does not support switching to legacy mode, and is therefore currently
incompatible with this image.

On Ubuntu or Debian:

```
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
update-alternatives --set arptables /usr/sbin/arptables-legacy
update-alternatives --set ebtables /usr/sbin/ebtables-legacy
```

On Fedora:

```
update-alternatives --set iptables /usr/sbin/iptables-legacy
```

Then reboot to apply changes.

### Use fail2ban-client

[Fail2ban commands](http://www.fail2ban.org/wiki/index.php/Commands) can be used through the container. Here is an
example if you want to ban an IP manually :

```
docker exec -t <CONTAINER> fail2ban-client set <JAIL> banip <IP>
``` 

### Global jail configuration

You can provide customizations in `/data/jail.d/*.local` files.

For example to change the default bantime for all jails, send an e-mail with whois report and relevant log lines
to the destemail:

```
[DEFAULT]
bantime = 1h
destemail = root@localhost
sender = root@$(hostname -f)
action = %(action_mwl)s
```

> :warning: If you want email to be sent after a ban, you have to configure SSMTP env vars

FYI, here is the order *jail* configuration would be loaded:

```
jail.conf
jail.d/*.conf (in alphabetical order)
jail.local
jail.d/*.local (in alphabetical order)
```

A sample configuration file is [available on the official repository](https://github.com/fail2ban/fail2ban/blob/master/config/jail.conf).

### Custom jails, actions and filters

Custom jails, actions and filters can be added respectively in `/data/jail.d`, `/data/action.d` and `/data/filter.d`.
If you add an action/filter that already exists, it will be overriden.

> :warning: Container has to be restarted to propagate changes

## How can I help?

All kinds of contributions are welcome :raised_hands:! The most basic way to show your support is to star :star2: the
project, or to raise issues :speech_balloon: You can also support this project by
[**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max) :clap: or by making a
[Paypal donation](https://www.paypal.me/crazyws) to ensure this journey continues indefinitely! :rocket:

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.
