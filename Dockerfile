# syntax=docker/dockerfile:1

ARG FAIL2BAN_VERSION=1.1.0
ARG ALPINE_VERSION=3.24
ARG DEBIAN_VERSION=trixie-slim

FROM --platform=$BUILDPLATFORM scratch AS src
ARG FAIL2BAN_VERSION
ADD "https://github.com/fail2ban/fail2ban.git#${FAIL2BAN_VERSION}" .

FROM debian:${DEBIAN_VERSION} AS debian
ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=from=src,target=/tmp/fail2ban,rw \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    grep \
    ipset \
    iptables \
    jq \
    kmod \
    mmdb-bin \
    nftables \
    openssh-client \
    python3 \
    python3-dnspython \
    python3-pyinotify \
    python3-setuptools \
    python3-systemd \
    tzdata \
    wget \
    whois \
  && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
  && cd /tmp/fail2ban \
  && python3 setup.py install --without-tests \
  && apt-get purge -y --auto-remove \
    build-essential \
    python3-dev \
  && apt-get clean \
  && rm -rf /etc/fail2ban/jail.d /root/.cache /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENV TZ="UTC"

VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "fail2ban-server", "-f", "-x", "-v", "start" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping || exit 1

FROM alpine:${ALPINE_VERSION} AS alpine
RUN --mount=from=src,target=/tmp/fail2ban,rw \
  apk add --no-cache \
    bash \
    curl \
    grep \
    ipset \
    iptables \
    iptables-legacy \
    jq \
    kmod \
    libmaxminddb \
    nftables \
    openssh-client-default \
    python3 \
    py3-dnspython \
    py3-inotify \
    py3-setuptools \
    tzdata \
    wget \
    whois \
  && apk add --no-cache -t build-dependencies \
    build-base \
    py3-pip \
    python3-dev \
  && cd /tmp/fail2ban \
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
