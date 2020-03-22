# Changelog

## 0.11.1-RC2 (2020/03/22)

* SSMTP: Add support for non-STARTTLS connections (#38)

## 0.11.1-RC1 (2020/01/18)

* Fail2ban 0.11.1

> :warning: **UPGRADE NOTES**
> `F2B_BACKEND`, `F2B_MAX_RETRY`, `F2B_MAX_MATCHES`, `F2B_DEST_EMAIL`, `F2B_SENDER`, `F2B_ACTION` env vars have been removed.
> You must now use them through the global jail configuration. See [README](README.md#global-jail-configuration) for more info.

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

* Add `kmod` (Issue #23)

## 0.10.4-RC7 (2019/05/03)

* Add `F2B_LOG_TARGET` var (Issue #22)

## 0.10.4-RC6 (2019/04/24)

* Add `ip6tables`

## 0.10.4-RC5 (2019/01/31)

* Alpine Linux 3.9

## 0.10.4-RC4 (2018/11/18)

* Add `F2B_IPTABLES_CHAIN` var to specify the iptables chain to which the Fail2Ban rules should be added
* Change default action to `%(action_)s`
* Add ipset

## 0.10.4-RC3 (2018/10/06)

* Add whois (Issue #6)

## 0.10.4-RC2 (2018/10/05)

* Allow to add custom actions and filters through `/data/action.d` and `/data/filter.d` folders (Issue #4)
* Relocate database to `/data/db` and jails to `/data/jail.d` (breaking change, see README.md)

## 0.10.4-RC1 (2018/10/04)

* Fail2ban 0.10.4

## 0.10.3.1-RC4 (2018/08/19)

* Add curl (Issue #1)

## 0.10.3.1-RC3 (2018/07/28)

* Upgrade based image to Alpine Linux 3.8
* Unset sensitive vars

## 0.10.3.1-RC2 (2018/05/07)

* Add mail alerts configurations with SSMTP
* Add healthcheck

## 0.10.3.1-RC1 (2018/04/25)

* Initial version based on Fail2ban 0.10.3.1
