<p align="center"><a href="https://github.com/crazy-max/docker-fail2ban" target="_blank"><img height="128"src="https://raw.githubusercontent.com/crazy-max/docker-fail2ban/master/.res/docker-fail2ban.jpg"></a></p>

<p align="center">
  <a href="https://microbadger.com/images/crazymax/fail2ban"><img src="https://images.microbadger.com/badges/version/crazymax/fail2ban.svg?style=flat-square" alt="Version"></a>
  <a href="https://travis-ci.org/crazy-max/docker-fail2ban"><img src="https://img.shields.io/travis/crazy-max/docker-fail2ban/master.svg?style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/fail2ban/"><img src="https://img.shields.io/docker/stars/crazymax/fail2ban.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/fail2ban/"><img src="https://img.shields.io/docker/pulls/crazymax/fail2ban.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://quay.io/repository/crazymax/fail2ban"><img src="https://quay.io/repository/crazymax/fail2ban/status?style=flat-square" alt="Docker Repository on Quay"></a>
  <a href="https://www.codacy.com/app/crazy-max/docker-fail2ban"><img src="https://img.shields.io/codacy/grade/10a198e9cd7948a6a2d71d9ca10548d1.svg?style=flat-square" alt="Code Quality"></a>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FRCLKDGE2CQFJ"><img src="https://img.shields.io/badge/donate-paypal-7057ff.svg?style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [Fail2ban](https://www.fail2ban.org) Docker image based on Alpine Linux.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other 🐳 Docker images!

## Docker

### Environment variables

* `TZ` : The timezone assigned to the container (default `UTC`)
* `F2B_LOG_LEVEL` : Log level output (default `INFO`)
* `F2B_DB_PURGE_AGE` : Age at which bans should be purged from the database (default `1d`)
* `F2B_MAX_RETRY` : Number of failures before a host get banned (default `5`)
* `F2B_DEST_EMAIL` : Destination email address used solely for the interpolations in configuration files (default `root@localhost`)
* `F2B_SENDER` : Sender email address used solely for some actions (default `root@$(hostname -f)`)
* `F2B_ACTION` : Default action on ban (default `%(action_)s`)
* `F2B_IPTABLES_CHAIN` : Specifies the iptables chain to which the Fail2Ban rules should be added (default `DOCKER-USER`)
* `SSMTP_HOST` : SMTP server host
* `SSMTP_PORT` : SMTP server port (default `25`)
* `SSMTP_HOSTNAME` : Full hostname (default `$(hostname -f)`)
* `SSMTP_USER` : SMTP username
* `SSMTP_PASSWORD` : SMTP password
* `SSMTP_TLS` : SSL/TLS (default `NO`)

> :warning: If you want email to be sent after a ban, you have to configure SSMTP env vars and set F2B_ACTION to `%(action_mw)s` or `%(action_mwl)s`

### Volumes

* `/data` : Contains customs jails, actions and filters and Fail2ban persistent database

## Use this image

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of folder [examples/compose](examples/compose) in `/var/fail2ban/` on your host for example. Edit the compose and env files with your preferences and run the following commands :

```bash
docker-compose up -d
docker-compose logs -f
```

### Command line

You can also use the following minimal command :

```bash
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

### Use fail2ban-client

[Fail2ban commands](http://www.fail2ban.org/wiki/index.php/Commands) can be used through the container. Here is an example if you want to ban an IP manually :

```bash
docker exec -t <CONTAINER> fail2ban-client set <JAIL> banip <IP>
```

### Custom actions and filters

Custom actions and filters can be added in `/data/action.d` and `/data/filter.d`. If you add an action/filter that already exists, it will be overriden.

> :warning: Container has to be restarted to propagate changes

### Jails examples

Examples of Fail2Ban jails can be found in [examples/jails](examples/jails).

To use for example the sshd jail, copy [`sshd.conf`](examples/jails/sshd/jail.d/sshd.conf) jail to `$(pwd)/jail.d` and start the container :

```bash
docker run -it --name fail2ban --restart always \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  -v $(pwd)/data:/data \
  -v /var/log:/var/log:ro \
  -e F2B_LOG_LEVEL=DEBUG \
  crazymax/fail2ban:latest
```

Here is the log output if an IP is banned :

```
2018-11-18 21:38:42,410 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-11-18 21:38:44,427 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-11-18 21:38:44,427 fail2ban.filter         [1]: DEBUG   Processing line with time:1542573523.0 and ip:192.168.51.100
2018-11-18 21:38:44,428 fail2ban.filter         [1]: INFO    [sshd] Found 192.168.51.100 - 2018-11-18 21:38:43
2018-11-18 21:38:44,428 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 1. Current failures from 1 IPs (IP:count): 192.168.51.100:1
2018-11-18 21:38:52,580 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-11-18 21:38:52,580 fail2ban.filter         [1]: DEBUG   Processing line with time:1542573532.0 and ip:192.168.51.100
2018-11-18 21:38:52,580 fail2ban.filter         [1]: INFO    [sshd] Found 192.168.51.100 - 2018-11-18 21:38:52
2018-11-18 21:38:52,581 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 2. Current failures from 1 IPs (IP:count): 192.168.51.100:2
2018-11-18 21:38:55,196 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-11-18 21:38:57,206 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-11-18 21:38:57,413 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-11-18 21:38:57,414 fail2ban.filter         [1]: DEBUG   Processing line with time:1542573537.0 and ip:192.168.51.100
2018-11-18 21:38:57,414 fail2ban.filter         [1]: INFO    [sshd] Found 192.168.51.100 - 2018-11-18 21:38:57
2018-11-18 21:38:57,414 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 3. Current failures from 1 IPs (IP:count): 192.168.51.100:3
2018-11-18 21:38:58,626 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-11-18 21:38:59,230 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-11-18 21:38:59,230 fail2ban.filter         [1]: DEBUG   Processing line with time:1542573538.0 and ip:192.168.51.100
2018-11-18 21:38:59,230 fail2ban.filter         [1]: INFO    [sshd] Found 192.168.51.100 - 2018-11-18 21:38:58
2018-11-18 21:38:59,230 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 4. Current failures from 1 IPs (IP:count): 192.168.51.100:4
2018-11-18 21:39:01,242 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-11-18 21:39:01,242 fail2ban.filter         [1]: DEBUG   Processing line with time:1542573540.0 and ip:192.168.51.100
2018-11-18 21:39:01,243 fail2ban.filter         [1]: INFO    [sshd] Found 192.168.51.100 - 2018-11-18 21:39:00
2018-11-18 21:39:01,243 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 5. Current failures from 1 IPs (IP:count): 192.168.51.100:5
2018-11-18 21:39:01,330 fail2ban.actions        [1]: NOTICE  [sshd] Ban 192.168.51.100
2018-11-18 21:39:01,331 fail2ban.action         [1]: DEBUG   iptables -w -N f2b-sshd
iptables -w -A f2b-sshd -j RETURN
iptables -w -I DOCKER-USER -p tcp -m multiport --dports ssh -j f2b-sshd
2018-11-18 21:39:01,357 fail2ban.utils          [1]: DEBUG   7fdf90f4fd50 -- returned successfully 0
2018-11-18 21:39:01,358 fail2ban.action         [1]: DEBUG   iptables -w -n -L DOCKER-USER | grep -q 'f2b-sshd[ \t]'
2018-11-18 21:39:01,372 fail2ban.utils          [1]: DEBUG   7fdf90ebdf30 -- returned successfully 0
2018-11-18 21:39:01,375 fail2ban.action         [1]: DEBUG   iptables -w -I f2b-sshd 1 -s 192.168.51.100 -j REJECT --reject-with icmp-port-unreachable
2018-11-18 21:39:01,394 fail2ban.utils          [1]: DEBUG   7fdf90ecbe30 -- returned successfully 0
2018-11-18 21:39:01,395 fail2ban.actions        [1]: DEBUG   Banned 1 / 1, 1 ticket(s) in 'sshd'
```

## How can I help ?

All kinds of contributions are welcome :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
But we're not gonna lie to each other, I'd rather you buy me a beer or two :beers:!

[![Paypal](.res/paypal.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FRCLKDGE2CQFJ)

## License

MIT. See `LICENSE` for more details.<br />
