#!/bin/bash

set -e

if [ ! -f "/.influxdb_configured" ]; then
    /etc/set_influxdb.sh
fi
exit 0
