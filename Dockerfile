# syntax=docker/dockerfile:1

ARG FAIL2BAN_VERSION=1.1.0
ARG ALPINE_VERSION=3.22

FROM --platform=$BUILDPLATFORM scratch AS src
ARG FAIL2BAN_VERSION
ADD "https://github.com/fail2ban/fail2ban.git#${FAIL2BAN_VERSION}" .

FROM alpine:${ALPINE_VERSION}
RUN --mount=from=src,target=/tmp/fail2ban,rw \
  apk add --no-cache \
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
  && apk add --no-cache -t build-dependencies \
    build-base \
    py3-pip \
    py3-setuptools \
    py3-wheel \
    python3-dev \
  && python3 -m pip install \
    --no-cache-dir \
    --no-build-isolation \
    --use-pep517 \
    --root-user-action=ignore \
    --break-system-packages \
    /tmp/fail2ban \
  && apk del build-dependencies \
  && rm -rf /etc/fail2ban/jail.d /root/.cache

COPY entrypoint.sh /entrypoint.sh

ENV TZ="UTC"

VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "fail2ban-server", "-f", "-x", "-v", "start" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping || exit 1
