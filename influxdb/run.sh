#!/bin/bash

set -m

CONFIG_FILE="/etc/influxdb/config.toml"

exec /etc/configure.sh

echo "=> Starting InfluxDB ..."
exec /usr/bin/influxd -config=${CONFIG_FILE}
