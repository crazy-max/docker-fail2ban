#!/bin/sh

TZ=${TZ:-"UTC"}
LOG_LEVEL=${LOG_LEVEL:-"INFO"}
DB_PURGE_AGE=${DB_PURGE_AGE:-"1d"}

# Timezone
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

# Fail2ban conf
sed -i "s/logtarget =.*/logtarget = STDOUT/g" /etc/fail2ban/fail2ban.conf
sed -i "s/loglevel =.*/loglevel = $LOG_LEVEL/g" /etc/fail2ban/fail2ban.conf
sed -i "s/dbpurgeage =.*/dbpurgeage = $DB_PURGE_AGE/g" /etc/fail2ban/fail2ban.conf

exec "$@"
