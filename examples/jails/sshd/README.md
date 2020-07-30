## SSHD

To block IPs that have SSHD authentication failures on your host, you have to :

* Copy files [jail.d](jail.d) to `./data`

For example :

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
