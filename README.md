# scripts
Scripts


#getstats.sh
mkdir -p /var/log/server-status; wget -O /var/log/server-status/getstats.sh https://raw.githubusercontent.com/Vudubond/scripts/main/cPanel/getstats.sh; echo "* * * * * root /usr/bin/flock -n /var/run/cloudlinux_getstats.cronlock /bin/sh /var/log/server-status/getstats.sh >/dev/null 2>&1" > /etc/cron.d/getstats.sh; chown 655 /var/log/server-status/getstats.sh; yum install perf -y;
