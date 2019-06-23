# Changelog

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
