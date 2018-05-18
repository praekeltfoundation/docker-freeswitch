FROM debian:jessie-slim
LABEL maintainer "Praekelt.org <sre@praekelt.org>"

# Add FreeSWITCH 1.6 repo
RUN echo 'deb http://files.freeswitch.org/repo/deb/freeswitch-1.6 jessie main' \
        > /etc/apt/sources.list.d/freeswitch.list \
    && apt-key adv --keyserver pool.sks-keyservers.net --recv-key 20B06EE621AB150D40F6079FD76EDC7725E010CF

# Install FreeSWITCH and necessary modules
ENV FREESWITCH_VERSION 1.6.20~37~987c9b9-1~jessie+1
RUN set -ex; \
    packages=' \
        freeswitch \
        freeswitch-conf-vanilla \
        freeswitch-meta-vanilla \
        freeswitch-mod-flite \
        freeswitch-mod-shout \
    '; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        $(for package in $packages; do echo "$package=$FREESWITCH_VERSION"; done); \
    rm -rf /var/lib/apt/lists/*

# Copy the "vanilla" configuration files
RUN cp -a /usr/share/freeswitch/conf/vanilla/. /etc/freeswitch/
COPY config/ /etc/freeswitch/

# Disable the example gateway and the IPv6 SIP profiles
RUN set -ex; \
    cd /etc/freeswitch; \
    mv directory/default/example.com.xml directory/default/example.com.xml.noload; \
    mv sip_profiles/external-ipv6.xml sip_profiles/external-ipv6.xml.noload; \
    mv sip_profiles/internal-ipv6.xml sip_profiles/internal-ipv6.xml.noload

# Don't expose any ports - use host networking

# Set up the entrypoint
COPY entrypoint.sh /usr/local/bin/freeswitch-entrypoint.sh
ENTRYPOINT ["freeswitch-entrypoint.sh"]
CMD ["-c", "-u", "freeswitch", "-g", "freeswitch"]
