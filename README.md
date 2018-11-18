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

* `TZ` : The timezone assigned to the container (default: `UTC`)
* `F2B_LOG_LEVEL` : Log level output (default: `INFO`)
* `F2B_DB_PURGE_AGE` : Age at which bans should be purged from the database (default: `1d`)
* `F2B_MAX_RETRY` : Number of failures before a host get banned (default: `5`)
* `F2B_DEST_EMAIL` : Destination email address used solely for the interpolations in configuration files (default: `root@localhost`)
* `F2B_SENDER` : Sender email address used solely for some actions (default: `root@$(hostname -f)`)
* `F2B_ACTION` : Default action on ban (default: `%(action_mwl)s`)
* `SSMTP_HOST` : SMTP server host
* `SSMTP_PORT` : SMTP server port (default: `25`)
* `SSMTP_HOSTNAME` : Full hostname (default: `$(hostname -f)`)
* `SSMTP_USER` : SMTP username
* `SSMTP_PASSWORD` : SMTP password
* `SSMTP_TLS` : SSL/TLS (default: `NO`)

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

### Example with sshd jail

Create a new jail file called `sshd.conf` in `$(pwd)/jail.d` :

```
[sshd]
enabled     = true
port        = ssh
filter      = sshd[mode=aggressive]
logpath     = /var/log/auth.log
maxretry    = 5
```

And start the container :

```bash
docker run -it --network host --cap-add NET_ADMIN --cap-add NET_RAW --name fail2ban \
  -v $(pwd)/data:/data \
  -v /var/log:/var/log:ro \
  -e F2B_LOG_LEVEL=DEBUG \
  crazymax/fail2ban:latest
```

Here is the log output if an IP is banned :

```
2018-04-25 00:07:01,984 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-04-25 00:07:03,325 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-04-25 00:07:08,538 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-04-25 00:07:08,546 fail2ban.filter         [1]: DEBUG   Processing line with time:1524607628.0 and ip:198.51.100.0
2018-04-25 00:07:08,548 fail2ban.filter         [1]: INFO    [sshd] Found 198.51.100.0 - 2018-04-25 00:07:08
2018-04-25 00:07:08,549 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 1. Current failures from 1 IPs (IP:count): 198.51.100.0:1
2018-04-25 00:07:14,563 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-04-25 00:07:14,566 fail2ban.filter         [1]: DEBUG   Processing line with time:1524607634.0 and ip:198.51.100.0
2018-04-25 00:07:14,567 fail2ban.filter         [1]: INFO    [sshd] Found 198.51.100.0 - 2018-04-25 00:07:14
2018-04-25 00:07:14,568 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 2. Current failures from 1 IPs (IP:count): 198.51.100.0:2
2018-04-25 00:07:17,775 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-04-25 00:07:17,782 fail2ban.filter         [1]: DEBUG   Processing line with time:1524607637.0 and ip:198.51.100.0
2018-04-25 00:07:17,784 fail2ban.filter         [1]: INFO    [sshd] Found 198.51.100.0 - 2018-04-25 00:07:17
2018-04-25 00:07:17,785 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 3. Current failures from 1 IPs (IP:count): 198.51.100.0:3
2018-04-25 00:07:19,792 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-04-25 00:07:19,795 fail2ban.filter         [1]: DEBUG   Processing line with time:1524607639.0 and ip:198.51.100.0
2018-04-25 00:07:19,797 fail2ban.filter         [1]: INFO    [sshd] Found 198.51.100.0 - 2018-04-25 00:07:19
2018-04-25 00:07:19,798 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 4. Current failures from 1 IPs (IP:count): 198.51.100.0:4
2018-04-25 00:07:21,003 fail2ban.filterpoll     [1]: DEBUG   /var/log/auth.log has been modified
2018-04-25 00:07:21,007 fail2ban.filter         [1]: DEBUG   Processing line with time:1524607640.0 and ip:198.51.100.0
2018-04-25 00:07:21,007 fail2ban.filter         [1]: INFO    [sshd] Found 198.51.100.0 - 2018-04-25 00:07:20
2018-04-25 00:07:21,008 fail2ban.failmanager    [1]: DEBUG   Total # of detected failures: 5. Current failures from 1 IPs (IP:count): 198.51.100.0:5
2018-04-25 00:07:21,407 fail2ban.actions        [1]: NOTICE  [sshd] Ban 198.51.100.0
2018-04-25 00:07:21,410 fail2ban.action         [1]: DEBUG   iptables -w -N f2b-sshd
iptables -w -A f2b-sshd -j RETURN
iptables -w -I INPUT -p tcp -m multiport --dports 22 -j f2b-sshd
2018-04-25 00:07:21,464 fail2ban.utils          [1]: DEBUG   7f6c759a3c00 -- returned successfully 0
2018-04-25 00:07:21,467 fail2ban.action         [1]: DEBUG   iptables -w -n -L INPUT | grep -q 'f2b-sshd[ \t]'
2018-04-25 00:07:21,483 fail2ban.utils          [1]: DEBUG   7f6c74bd2ce8 -- returned successfully 0
2018-04-25 00:07:21,485 fail2ban.action         [1]: DEBUG   iptables -w -I f2b-sshd 1 -s 198.51.100.0 -j REJECT --reject-with icmp-port-unreachable
2018-04-25 00:07:21,511 fail2ban.utils          [1]: DEBUG   7f6c7591d4b0 -- returned successfully 0
2018-04-25 00:07:21,512 fail2ban.actions        [1]: DEBUG   Banned 1 / 1, 1 ticket(s) in 'sshd'
```

### Use fail2ban-client

[Fail2ban commands](http://www.fail2ban.org/wiki/index.php/Commands) can be used through the container. Here is an example if you want to ban an IP manually :

```bash
docker exec -it <CONTAINER> fail2ban-client set <JAIL> banip <IP>
```

### Custom actions and filters

Custom actions and filters can be added in `/data/action.d` and `/data/filter.d`. If you add an action/filter that already exists, it will be overriden.

> :warning: Container has to be restarted to propagate changes

## How can I help ?

All kinds of contributions are welcome :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
But we're not gonna lie to each other, I'd rather you buy me a beer or two :beers:!

[![Paypal](.res/paypal.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FRCLKDGE2CQFJ)

## License

MIT. See `LICENSE` for more details.<br />
