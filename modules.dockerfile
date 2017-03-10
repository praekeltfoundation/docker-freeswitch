FROM debian:jessie

# Install rust toolchain and build mod_prometheus
ENV RUST_VERSION=1.15.1
ENV DOWNLOAD_CHECKSUM=b1e7c818a3cc8b010932f0efc1cf0ede7471958310f808d543b6e32d2ec748e7
RUN set -ex && apt-get update && apt-get -y install build-essential curl git-core && \
    curl -s https://static.rust-lang.org/dist/rust-$RUST_VERSION-x86_64-unknown-linux-gnu.tar.gz -o rust.tar.gz && \
    echo "$DOWNLOAD_CHECKSUM  rust.tar.gz"|shasum -c - && \
    tar zxf rust.tar.gz && ./rust-$RUST_VERSION-x86_64-unknown-linux-gnu/install.sh

# Build the module
ENV MODULE_SHA=d7cfed7
CMD set -ex && git clone https://github.com/moises-silva/mod_prometheus.git \
    && cd mod_prometheus \
    && git checkout $MODULE_SHA \
    && cargo build \
    && cp target/debug/libmod_prometheus.so /tmp/build/modules/
