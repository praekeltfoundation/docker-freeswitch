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

function fs_cli_command() {
  docker exec freeswitch fs_cli -x "$*"
}

function module_exists {
  local module="$1"; shift
  [ $(fs_cli_command module_exists "$module") = 'true' ]
}

function http_check {
  local url="$1"; shift
  local code="$1"; shift
  [ $(curl -s -o /dev/null -w "%{http_code}" $url) = $code ]
}

set -x

docker run -p 6780:6780 -d --name freeswitch "$image"
# Set a trap to stop the container when we exit
trap "{ set +x; docker stop freeswitch; docker rm -f freeswitch; }" EXIT

wait_for_log_line 'FreeSWITCH Started'

# Check FreeSWITCH is run as the freeswitch user by default
# Need to specify width of user field or else it gets truncated
docker exec freeswitch ps ax --format 'user:10 pid command' | grep -E '^freeswitch .* freeswitch -c'

# Check console colorize is disabled
fs_cli_command console colorize | fgrep '+OK console color disabled'

# Check our modules are configured correctly
! module_exists mod_logfile
module_exists mod_h26x
module_exists mod_flite
module_exists mod_shout
module_exists libmod_prometheus

# No Sofia profiles (no default ones)
fs_cli_command sofia profile internal gwlist | fgrep -e '-ERR no reply'
fs_cli_command sofia profile external gwlist | fgrep -e '-ERR no reply'

set +x
echo
echo "PASSED"
