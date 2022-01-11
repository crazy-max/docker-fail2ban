ARG FAIL2BAN_VERSION="0.11.2"

FROM alpine:3.15

ARG FAIL2BAN_VERSION
RUN apk --update --no-cache add \
    bash \
    curl \
    grep \
    ipset \
    iptables \
    ip6tables \
    kmod \
    nftables \
    python3 \
    py3-setuptools \
    ssmtp \
    tzdata \
    wget \
    whois \
  && apk --update --no-cache add -t build-dependencies \
    build-base \
    py3-pip \
    python3-dev \
  && pip3 install --upgrade pip \
  && pip3 install dnspython3 pyinotify \
  && cd /tmp \
  && curl -SsOL https://github.com/fail2ban/fail2ban/archive/${FAIL2BAN_VERSION}.zip \
  && unzip ${FAIL2BAN_VERSION}.zip \
  && cd fail2ban-${FAIL2BAN_VERSION} \
  && 2to3 -w --no-diffs bin/* fail2ban \
  && python3 setup.py install \
  && apk del build-dependencies \
  && rm -rf /etc/fail2ban/jail.d /tmp/*

COPY entrypoint.sh /entrypoint.sh

ENV TZ="UTC"

VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "fail2ban-server", "-f", "-x", "-v", "start" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping || exit 1
