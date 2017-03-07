#!/usr/bin/env bash
set -e

function usage() {
  echo "usage: $1 IMAGE"
  echo " e.g.: $1 praekeltfoundation/freeswitch"
}

image="$1"
shift || { usage "$0" >&2; exit 1; }

# Set a trap on errors to make it clear when tests have failed
trap '{ set +x; echo; echo FAILED; echo; } >&2' ERR

# macOS-compatible timeout function: http://stackoverflow.com/a/35512328
function timeout() { perl -e 'alarm shift; exec @ARGV' "$@"; }

function wait_for_log_line() {
  local log_pattern="$1"; shift
  timeout "${LOG_TIMEOUT:-20}" grep -m 1 -E "$log_pattern" <(docker logs -f freeswitch 2>&1)
}

function module_exists {
  local module="$1"; shift
  [ $(docker exec freeswitch fs_cli -x "module_exists $module") = 'true' ]
}

set -x

docker run -d --name freeswitch "$image"
# Set a trap to stop the container when we exit
trap "{ set +x; docker stop freeswitch; docker rm -f freeswitch; }" EXIT

wait_for_log_line 'FreeSWITCH Started'

# Check our modules are configured correctly
! module_exists mod_logfile
module_exists mod_h26x
module_exists mod_flite
module_exists mod_shout

set +x
echo
echo "PASSED"
