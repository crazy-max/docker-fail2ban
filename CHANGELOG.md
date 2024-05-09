# Changelog

## 1.1.0-r1 (2024/05/09)

* Support iptables-legacy for old kernels (#165)
* Fallback to iptables-legacy if host doesn't support nft. Mode can be enforced
  with `IPTABLES_MODE` env var (#167)

## 1.1.0-r0 (2024/05/01)

* Fail2ban 1.1.0 (#162)
* Alpine Linux 3.19 (#163)

## 1.0.2-r1 (2023/08/29)

* Alpine Linux 3.18 (#149)

## 1.0.2-r0 (2022/12/29)

* Fail2ban 1.0.2 (#132)
* Alpine Linux 3.17 (#135)

## 1.0.1-r0 (2022/10/06)

* Fail2ban 1.0.1 (#130)
* Alpine Linux 3.16 (#126)

## 0.11.2-r4 (2022/01/11)

* Add SSH client (#110)
* Alpine Linux 3.15 (#109)

## 0.11.2-r3 (2021/09/25)

* Add `grep` (#102)

## 0.11.2-r2 (2021/08/19)

* Alpine Linux 3.14 (#100)
* Switch to buildx bake (#90)

## 0.11.2-RC1 (2020/12/23)

* Fail2ban 0.11.2

## 0.11.1-RC5 (2020/11/22)

* Rebuild to fix tzdata issue with Alpine

## 0.11.1-RC4 (2020/11/22)

* Add `SSMTP_PASSWORD_FILE` env var

## 0.11.1-RC3 (2020/07/30)

* Bringing the `INPUT` and `DOCKER-USER` chains together (#17 #46)
* Remove `F2B_IPTABLES_CHAIN` env var
* Update jails examples
* Alpine Linux 3.12

> :warning: **UPGRADE NOTES**
> `F2B_IPTABLES_CHAIN` env var have been removed.
> You must now define the targeted chain in your jail definition.
> See [README](README.md#docker-user-and-input-chains) for more info.

## 0.11.1-RC2 (2020/03/22)

* SSMTP: Add support for non-STARTTLS connections (#38)

## 0.11.1-RC1 (2020/01/18)

* Fail2ban 0.11.1

> :warning: **UPGRADE NOTES**
> `F2B_BACKEND`, `F2B_MAX_RETRY`, `F2B_MAX_MATCHES`, `F2B_DEST_EMAIL`, `F2B_SENDER`, `F2B_ACTION` env vars have been removed.
> You must now use them through the global jail configuration.
> See [README](README.md#global-jail-configuration) for more info.

## 0.10.5-RC1 (2020/01/17)

* Fail2ban 0.10.5
* Add nftables support
* Add `F2B_MAX_MATCHES` env var
* Alpine Linux 3.11

## 0.10.4-RC13 (2019/12/07)

* Fix timezone

## 0.10.4-RC12 (2019/10/03)

* Multi-platform Docker image
* Switch to GitHub Actions
* :warning: Stop publishing Docker image on Quay
* Set timezone through tzdata

## 0.10.4-RC11 (2019/09/16)

* Only populate AuthUser/Pass in ssmtp.conf if defined in ENV (PR #28)

## 0.10.4-RC10 (2019/08/13)

* Add option `F2B_BACKEND` to change default backend
* Add dnspython3 and pyinotify
* Update to Python 3

## 0.10.4-RC9 (2019/06/23)

* Alpine Linux 3.10

## 0.10.4-RC8 (2019/05/06)

* Add `kmod` (#23)

## 0.10.4-RC7 (2019/05/03)

* Add `F2B_LOG_TARGET` var (#22)

## 0.10.4-RC6 (2019/04/24)

* Add `ip6tables`

## 0.10.4-RC5 (2019/01/31)

* Alpine Linux 3.9

## 0.10.4-RC4 (2018/11/18)

* Add `F2B_IPTABLES_CHAIN` var to specify the iptables chain to which the Fail2Ban rules should be added
* Change default action to `%(action_)s`
* Add ipset

## 0.10.4-RC3 (2018/10/06)

* Add `whois` (#6)

## 0.10.4-RC2 (2018/10/05)

* Allow to add custom actions and filters through `/data/action.d` and `/data/filter.d` folders (#4)
* Relocate database to `/data/db` and jails to `/data/jail.d` (breaking change, see README.md)

## 0.10.4-RC1 (2018/10/04)

* Fail2ban 0.10.4

## 0.10.3.1-RC4 (2018/08/19)

* Add `curl` (#1)

## 0.10.3.1-RC3 (2018/07/28)

* Upgrade based image to Alpine Linux 3.8
* Unset sensitive vars

## 0.10.3.1-RC2 (2018/05/07)

* Add mail alerts configurations with SSMTP
* Add healthcheck

## 0.10.3.1-RC1 (2018/04/25)

* Initial version based on Fail2ban 0.10.3.1
