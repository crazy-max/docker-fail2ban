FROM alpine:3.7
MAINTAINER CrazyMax <crazy-max@users.noreply.github.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="fail2ban" \
  org.label-schema.description="Fail2ban image based on Alpine Linux" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-fail2ban" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-fail2ban" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

ARG FAIL2BAN_VERSION=0.10.3.1

RUN apk --update --no-cache add \
    iptables python3 python3-dev py-setuptools ssmtp tzdata wget \
  && cd /tmp && wget https://github.com/fail2ban/fail2ban/archive/${FAIL2BAN_VERSION}.zip \
  && unzip ${FAIL2BAN_VERSION}.zip \
  && cd fail2ban-${FAIL2BAN_VERSION} \
  && python setup.py install \
  && cp -f /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.or \
  && rm -rf /var/cache/apk/* /tmp/*

ADD entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

VOLUME [ "/etc/fail2ban/jail.d", "/var/lib/fail2ban" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "fail2ban-server", "-f", "-x", "-v", "start" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping
