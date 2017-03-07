#!/bin/bash -e

# First argument looks like an option for FreeSWITCH
if [ "${1:0:1}" = '-' ]; then
  set -- freeswitch "$@"
fi

exec "$@"
