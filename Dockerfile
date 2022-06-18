# syntax=docker/dockerfile:1

ARG FAIL2BAN_VERSION=0.11.2
ARG ALPINE_VERSION=3.16

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS fail2ban-src
RUN apk add --no-cache git patch
WORKDIR /src/fail2ban
ARG FAIL2BAN_VERSION
RUN <<EOT
git clone https://github.com/fail2ban/fail2ban.git .
git reset --hard $FAIL2BAN_VERSION
EOT
COPY patches /src/patches
RUN for i in /src/patches/*.patch; do patch -p1 < $i; done

FROM alpine:${ALPINE_VERSION}
RUN --mount=from=fail2ban-src,source=/src/fail2ban,target=/tmp/fail2ban,rw \
  apk --update --no-cache add \
    bash \
    curl \
    grep \
    ipset \
    iptables \
    ip6tables \
    kmod \
    nftables \
    openssh-client-default \
    python3 \
    ssmtp \
    tzdata \
    wget \
    whois \
  && apk --update --no-cache add -t build-dependencies \
    build-base \
    py3-pip \
    py3-setuptools \
    python3-dev \
  && pip3 install --upgrade pip \
  && pip3 install dnspython3 pyinotify \
  && cd /tmp/fail2ban \
  && 2to3 -w --no-diffs bin/* fail2ban \
  && python3 setup.py install \
  && apk del build-dependencies \
  && rm -rf /etc/fail2ban/jail.d

COPY entrypoint.sh /entrypoint.sh

ENV TZ="UTC"

VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "fail2ban-server", "-f", "-x", "-v", "start" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping || exit 1
