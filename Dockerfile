# syntax=docker/dockerfile:1

ARG FAIL2BAN_VERSION=1.1.0
ARG ALPINE_VERSION=3.21

FROM --platform=$BUILDPLATFORM scratch AS src
ARG FAIL2BAN_VERSION
ADD "https://github.com/fail2ban/fail2ban.git#${FAIL2BAN_VERSION}" .

FROM alpine:${ALPINE_VERSION}
RUN --mount=from=src,target=/tmp/fail2ban,rw \
  apk --update --no-cache add \
    bash \
    curl \
    grep \
    ipset \
    iptables \
    iptables-legacy \
    kmod \
    nftables \
    openssh-client-default \
    python3 \
    py3-dnspython \
    py3-inotify \
    tzdata \
    wget \
    whois \
  && apk --update --no-cache add -t build-dependencies \
    build-base \
    py3-pip \
    py3-setuptools \
    python3-dev \
  && cd /tmp/fail2ban \
  && 2to3 -w --no-diffs bin/* fail2ban \
  && python3 setup.py install --without-tests \
  && apk del build-dependencies \
  && rm -rf /etc/fail2ban/jail.d /root/.cache

COPY entrypoint.sh /entrypoint.sh

ENV TZ="UTC"

VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "fail2ban-server", "-f", "-x", "-v", "start" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping || exit 1
