# docker-freeswitch
Dockerfile for running [FreeSWITCH](https://freeswitch.org) in a Docker container.

* Base image: `debian:jessie`
* Exposed ports: None
* Volumes: None

### Packages
This is NOT a complete FreeSWITCH installation - the Docker image only contains the "meta-vanilla" packages as well as a couple of extra modules. FreeSWITCH is a very large software project with many submodules. We install only the features that *we* need. Still, this may be a useful starting point for anybody looking to run FreeSWITCH under Docker.

We install the following FreeSWITCH packages:
* `freeswitch-meta-vanilla`
* `freeswitch-mod-flite` (for text-to-speech)
* `freeswitch-mod-shout` (for playing audio from files)

### Networking
It is not recommended that you use Docker's bridge networking mode for FreeSWITCH as some of the protocols (namely, SIP) make use of a very large number of ports and it is not feasible to forward all of these ports to the host. Instead, consider using Docker's host networking mode or, in Docker 1.9+, the virtual overlay networking mode.

### Configuration
For the most part we use the default "vanilla" configuration that FreeSWITCH installs in `/usr/share/freeswitch/conf/vanilla`. However, we do override some of the configuration options. The changes are as follows:
* `autoload_configs/console.conf.xml`:
  * Disable console colorizing as this seems to break some logging systems.
* `autoload_configs/modules.conf.xml`:
  * Disable `mod_logfile` as the container logs are consumed from stdout/stderr, not a file.
  * Enable `mod_h26x` for H.263/4 CODEC support.
  * Enable `mod_flite`.
  * Enable `mod_shout`.
  * Adds and enables `libmod_prometheus`.
* `directory/default/example.com.xml`:
  * This file is renamed to prevent FreeSWITCH from setting up an example (and non-functional) SIP gateway.
