FROM	ubuntu:14.04

ENV GRAFANA_VERSION 4.2.0
ENV INFLUXDB_VERSION 1.2.0
ENV TELEGRAF_VERSION 1.2.1

# Prevent some error messages
ENV DEBIAN_FRONTEND noninteractive

#RUN	echo 'deb http://us.archive.ubuntu.com/ubuntu/ trusty universe' >> /etc/apt/sources.list
RUN		apt-get -y update && apt-get -y upgrade

# ---------------- #
#   Installation   #
# ---------------- #

RUN mkdir /data

# Install all prerequisites
RUN 	apt-get -y install wget nginx-light supervisor curl adduser libfontconfig redis-server

# Install Grafana
RUN wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb && \
		dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb && rm grafana_${GRAFANA_VERSION}_amd64.deb

# Install InfluxDB to /src/influxdb
RUN 	wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
			dpkg -i influxdb_${INFLUXDB_VERSION}_amd64.deb && rm influxdb_${INFLUXDB_VERSION}_amd64.deb

RUN		wget https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}_amd64.deb && \
			sudo dpkg -i telegraf_${TELEGRAF_VERSION}_amd64.deb

# ----------------- #
#   Configuration   #
# ----------------- #

# Configure InfluxDB
ADD		influxdb/config.toml /etc/influxdb/config.toml
ADD		influxdb/run.sh /usr/local/bin/run_influxdb
# These two databases have to be created. These variables are used by set_influxdb.sh and set_grafana.sh
ENV		INFLUXDB_URL http://127.0.0.1:8086

# Configure Grafana
ADD		./grafana/grafana.ini /etc/grafana/grafana.ini

ADD		./configure.sh /etc/configure.sh
ADD		./set_influxdb.sh /etc/set_influxdb.sh

# Configure nginx and supervisord
ADD		./nginx/nginx.conf /etc/nginx/nginx.conf
ADD		./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD ./redis/redis.conf /etc/redis/redis.conf

# Configure telegraph
ADD ./telegraf/telegraf.conf /etc/telegraf/telegraf.conf

# ----------- #
#   Cleanup   #
# ----------- #

RUN		apt-get autoremove -y wget curl && \
			apt-get -y clean && \
			rm -rf /var/lib/apt/lists/*

# ---------------- #
#   Expose Ports   #
# ---------------- #

# Grafana
EXPOSE	80

# StatsD
EXPOSE 8125/udp

# -------- #
#   Run!   #
# -------- #

CMD		["/usr/bin/supervisord"]
