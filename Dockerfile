FROM debian:jessie
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# Add Freeswitch 1.6 repo
RUN echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list \
    && apt-key adv --keyserver pool.sks-keyservers.net --recv-key D76EDC7725E010CF

ENV FREESWITCH_VERSION "1.6.15~32~bec4538-1~jessie+1"

# Install Freeswitch (use regular apt-get install to avoid weird dependency problems)
RUN apt-get update \
    && apt-get -qy install \
        freeswitch-meta-vanilla=$FREESWITCH_VERSION \
        freeswitch-mod-flite=$FREESWITCH_VERSION \
        freeswitch-mod-shout=$FREESWITCH_VERSION


# Copy basic configuration files
RUN cp -a /usr/share/freeswitch/conf/vanilla/. /etc/freeswitch/
COPY config/ /etc/freeswitch/

# Disable the example gateway
RUN mv /etc/freeswitch/directory/default/example.com.xml /etc/freeswitch/directory/default/example.com.noload

# Install rust toolchain
RUN apt-get -y install build-essential curl git-core
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y

ENV PATH=/root/.cargo/bin:$PATH

# Clone the project and build it:
RUN git clone https://github.com/moises-silva/mod_prometheus.git
RUN cd mod_prometheus && cargo build

# Copy the module to your FreeSWITCH modules directory:
RUN cp mod_prometheus/target/debug/libmod_prometheus.so /usr/lib/freeswitch/mod/

# Cleanup
RUN rm -rf .cargo mod_prometheus /var/lib/apt/lists/*
RUN apt-get -y purge build-essential curl git-core && apt-get -y autoremove

# Don't expose any ports - use host networking

# Run Freeswitch
CMD ["stdbuf", "-i0", "-o0", "-e0", "freeswitch", "-c"]
