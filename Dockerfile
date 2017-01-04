FROM debian:jessie
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Add Freeswitch 1.6 repo
RUN echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" \
        > /etc/apt/sources.list.d/freeswitch.list \
    && apt-key adv --keyserver pool.sks-keyservers.net --recv-key 20B06EE621AB150D40F6079FD76EDC7725E010CF

ENV FREESWITCH_VERSION "1.6.13~21~e755b43-1~jessie+1"

# Install Freeswitch (use regular apt-get install to avoid weird dependency problems)
RUN apt-get update \
    && apt-get -qy install \
        freeswitch-meta-vanilla=$FREESWITCH_VERSION \
        freeswitch-mod-flite=$FREESWITCH_VERSION \
        freeswitch-mod-shout=$FREESWITCH_VERSION \
    && rm -rf /var/lib/apt/lists/*

# Copy basic configuration files
RUN cp -a /usr/share/freeswitch/conf/vanilla/. /etc/freeswitch/
COPY config/ /etc/freeswitch/

# Disable the example gateway
RUN mv /etc/freeswitch/directory/default/example.com.xml \
       /etc/freeswitch/directory/default/example.com.xml.noload

# Don't expose any ports - use host networking

# Run Freeswitch
CMD ["stdbuf", "-i0", "-o0", "-e0", "freeswitch", "-c"]
