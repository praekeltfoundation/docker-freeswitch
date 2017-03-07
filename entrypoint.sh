#!/bin/bash -e

# First argument looks like an option for FreeSWITCH
if [ "${1:0:1}" = '-' ]; then
  set -- freeswitch "$@"
fi

# If we're running FreeSWITCH and are not in a terminal, then prevent FreeSWITCH
# from buffering I/O for its CLI.
if [ "$1" = 'freeswitch' ] && ! [ -t 1 ]; then
  set -- stdbuf -i0 -o0 -e0 "$@"
fi

exec "$@"
