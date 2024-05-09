# syntax=docker/dockerfile:1

ARG FAIL2BAN_VERSION=1.1.0
ARG ALPINE_VERSION=3.19

# https://github.com/kubernetes-sigs/iptables-wrappers
ARG IPTABLES_WRAPPER_VERSION=f6ef44b2c449cca8f005b32dea9a4b497202dbef
ARG GO_VERSION=1.21
ARG XX_VERSION=1.4.0

FROM --platform=${BUILDPLATFORM} tonistiigi/xx:${XX_VERSION} AS xx
FROM --platform=${BUILDPLATFORM} golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS iw-builder
RUN apk --update --no-cache add file
COPY --from=xx / /
WORKDIR /src
ARG IPTABLES_WRAPPER_VERSION
ADD "https://github.com/kubernetes-sigs/iptables-wrappers.git#${IPTABLES_WRAPPER_VERSION}" .
ARG TARGETPLATFORM
ENV CGO_ENABLED=0
RUN xx-go build -v -trimpath -o /bin/iptables-wrapper -ldflags='-s -w -extldflags="-static" -buildid=""' . \
  && xx-verify --static /bin/iptables-wrapper

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS fail2ban-src
RUN apk add --no-cache git
WORKDIR /src/fail2ban
RUN git init . && git remote add origin "https://github.com/fail2ban/fail2ban.git"
ARG FAIL2BAN_VERSION
RUN git fetch origin "${FAIL2BAN_VERSION}" && git checkout -q FETCH_HEAD

FROM alpine:${ALPINE_VERSION}
RUN --mount=from=fail2ban-src,source=/src/fail2ban,target=/tmp/fail2ban,rw \
  apk --update --no-cache add \
    bash \
    curl \
    grep \
    iproute2 \
    ipset \
    iptables \
    iptables-legacy \
    kmod \
    nftables \
    openssh-client-default \
    python3 \
    py3-dnspython \
    py3-inotify \
    ssmtp \
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

COPY --from=iw-builder /src/iptables-wrapper-installer.sh /
COPY --from=iw-builder /bin/iptables-wrapper /
RUN /iptables-wrapper-installer.sh --no-sanity-check

COPY entrypoint.sh /entrypoint.sh

ENV TZ="UTC"

VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "fail2ban-server", "-f", "-x", "-v", "start" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping || exit 1
