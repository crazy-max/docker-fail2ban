<p align="center"><a href="https://github.com/crazy-max/docker-fail2ban" target="_blank"><img height="128" src="https://raw.githubusercontent.com/crazy-max/docker-fail2ban/master/.github/docker-fail2ban.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/crazymax/fail2ban/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/crazy-max/docker-fail2ban?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/crazy-max/docker-fail2ban/actions?workflow=build"><img src="https://img.shields.io/github/actions/workflow/status/crazy-max/docker-fail2ban/build.yml?branch=master&label=build&logo=github&style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/fail2ban/"><img src="https://img.shields.io/docker/stars/crazymax/fail2ban.svg?style=flat-square&logo=docker" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/fail2ban/"><img src="https://img.shields.io/docker/pulls/crazymax/fail2ban.svg?style=flat-square&logo=docker" alt="Docker Pulls"></a>
  <br /><a href="https://github.com/sponsors/crazy-max"><img src="https://img.shields.io/badge/sponsor-crazy--max-181717.svg?logo=github&style=flat-square" alt="Become a sponsor"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

[Fail2ban](https://www.fail2ban.org) Docker image to ban hosts that cause
multiple authentication errors.

> [!TIP] 
> Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun)
> project!

___

* [Build locally](#build-locally)
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
  * [Use fail2ban-client](#use-fail2ban-client)
  * [Global jail configuration](#global-jail-configuration)
  * [Custom jails, actions and filters](#custom-jails-actions-and-filters)
  * [Sending email using a sidecar container](#sending-email-using-a-sidecar-container)
* [Contributing](#contributing)
* [License](#license)

## Build locally

```shell
git clone https://github.com/crazy-max/docker-fail2ban.git
cd docker-fail2ban

# Build image and output to docker (default)
docker buildx bake

# Build multi-platform image
docker buildx bake image-all
```

## Image

| Registry                                                                                            | Image                        |
|-----------------------------------------------------------------------------------------------------|------------------------------|
| [Docker Hub](https://hub.docker.com/r/crazymax/fail2ban/)                                           | `crazymax/fail2ban`          |
| [GitHub Container Registry](https://github.com/users/crazy-max/packages/container/package/fail2ban) | `ghcr.io/crazy-max/fail2ban` |

Following platforms for this image are available:

```
$ docker buildx imagetools inspect crazymax/fail2ban --format "{{json .Manifest}}" | \
  jq -r '.manifests[] | select(.platform.os != null and .platform.os != "unknown") | .platform | "\(.os)/\(.architecture)\(if .variant then "/" + .variant else "" end)"'

linux/386
linux/amd64
linux/arm/v6
linux/arm/v7
linux/arm64
linux/ppc64le
linux/riscv64
linux/s390x
```

## Environment variables

* `TZ`: The timezone assigned to the container (default `UTC`)
* `F2B_LOG_TARGET`: Set the log target. This could be a file, SYSLOG, STDERR or STDOUT (default `STDOUT`)
* `F2B_LOG_LEVEL`: Log level output (default `INFO`)
* `F2B_DB_PURGE_AGE`: Age at which bans should be purged from the database (default `1d`)
* `IPTABLES_MODE`: Choose between iptables `nft` or `legacy` mode. (default `auto`)

## Volumes

* `/data`: Contains customs jails, actions and filters and Fail2ban persistent database

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of
folder [examples/compose](examples/compose) in `/var/fail2ban/` on your host
for example. Edit the Compose and env files with your preferences and run the
following commands:

```console
$ docker compose up -d
$ docker compose logs -f
```

### Command line

You can also use the following minimal command :

```console
$ docker run -d --name fail2ban --restart always \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  -v $(pwd)/data:/data \
  -v /var/log:/var/log:ro \
  crazymax/fail2ban:latest
```

## Upgrade

Recreate the container whenever I push an update:

```console
$ docker compose pull
$ docker compose up -d
```

## Notes

### `DOCKER-USER` chain

In Docker 17.06 and higher through [docker/libnetwork#1675](https://github.com/docker/libnetwork/pull/1675),
you can add rules to a new table called `DOCKER-USER`, and these rules will be
loaded before any rules Docker creates automatically. This is useful to make
`iptables` rules created by Fail2Ban persistent.

If you have an older version of Docker, you may just change the chain
definition for your jail to `chain = FORWARD`. This way, all Fail2Ban rules
come before any Docker rules but these rules will now apply to ALL forwarded
traffic.

More info : https://docs.docker.com/network/iptables/

### `DOCKER-USER` and `INPUT` chains

If your Fail2Ban container is attached to `DOCKER-USER` chain instead of
`INPUT`, the rules will be applied **only to containers**. This means that any
packets coming into the `INPUT` chain will bypass these rules that now reside
under the `FORWARD` chain.

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

### Use fail2ban-client

[Fail2ban commands](http://www.fail2ban.org/wiki/index.php/Commands) can be used
through the container. Here is an example if you want to ban an IP manually:

```console
$ docker exec -t <CONTAINER> fail2ban-client set <JAIL> banip <IP>
```

### Global jail configuration

You can provide customizations in `/data/jail.d/*.local` files.

For example, to change the default bantime for all jails:

```text
[DEFAULT]
bantime = 1h
```

> [!NOTE]
> Loading order for jail configuration:
> ```text
> jail.conf
> jail.d/*.conf (in alphabetical order)
> jail.local
> jail.d/*.local (in alphabetical order)
> ```

A sample configuration file is [available on the official repository](https://github.com/fail2ban/fail2ban/blob/master/config/jail.conf).

### Custom jails, actions and filters

Custom jails, actions and filters can be added respectively in `/data/jail.d`,
`/data/action.d` and `/data/filter.d`. If you add an action/filter that already
exists, it will be overriden.

> [!WARNING]
> Container has to be restarted to propagate changes

### Sending email using a sidecar container

If you want to send emails using a sidecar container, see the example in
[examples/smtp](examples/smtp). It uses the [smtp.py action](https://github.com/fail2ban/fail2ban/blob/1.1.0/config/action.d/smtp.py)
and [msmtpd SMTP relay](https://github.com/crazy-max/docker-msmtpd) image.

## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star
the project, or to raise issues. You can also support this project by [**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max)
or by making a [PayPal donation](https://www.paypal.me/crazyws) to ensure this
journey continues indefinitely!

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.
