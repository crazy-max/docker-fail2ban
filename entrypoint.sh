#!/bin/sh

TZ=${TZ:-"UTC"}

F2B_LOG_LEVEL=${F2B_LOG_LEVEL:-"INFO"}
F2B_DB_PURGE_AGE=${F2B_DB_PURGE_AGE:-"1d"}
F2B_MAX_RETRY=${F2B_MAX_RETRY:-"5"}
F2B_DEST_EMAIL=${F2B_DEST_EMAIL:-"root@localhost"}
F2B_SENDER=${F2B_SENDER:-"root@$(hostname -f)"}
F2B_ACTION=${F2B_ACTION:-"%(action_mwl)s"}

SSMTP_PORT=${SSMTP_PORT:-"25"}
SSMTP_HOSTNAME=${SSMTP_HOSTNAME:-"$(hostname -f)"}
SSMTP_TLS=${SSMTP_TLS:-"NO"}

# Timezone
echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

# SSMTP
echo "Setting SSMTP configuration..."
if [ -z "$SSMTP_HOST" ] ; then
  echo "WARNING: SSMTP_HOST must be defined if you want fail2ban to send emails"
  cp -f /etc/ssmtp/ssmtp.conf.or /etc/ssmtp/ssmtp.conf
else
  cat > /etc/ssmtp/ssmtp.conf <<EOL
mailhub=${SSMTP_HOST}:${SSMTP_PORT}
hostname=${SSMTP_HOSTNAME}
FromLineOverride=YES
AuthUser=${SSMTP_USER}
AuthPass=${SSMTP_PASSWORD}
UseTLS=${SSMTP_TLS}
UseSTARTTLS=${SSMTP_TLS}
EOL
fi

# Fail2ban conf
echo "Setting Fail2ban configuration..."
sed -i "s/logtarget =.*/logtarget = STDOUT/g" /etc/fail2ban/fail2ban.conf
sed -i "s/loglevel =.*/loglevel = $F2B_LOG_LEVEL/g" /etc/fail2ban/fail2ban.conf
sed -i "s/dbpurgeage =.*/dbpurgeage = $F2B_DB_PURGE_AGE/g" /etc/fail2ban/fail2ban.conf
cat > /etc/fail2ban/jail.local <<EOL
[DEFAULT]
maxretry = ${F2B_MAX_RETRY}
destemail = ${F2B_DEST_EMAIL}
sender = ${F2B_SENDER}
action = ${F2B_ACTION}
EOL

exec "$@"
