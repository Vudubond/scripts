#!/bin/bash

# bash <(curl -s https://raw.githubusercontent.com/Vudubond/scripts/main/cPanel/kill_sleeping_mysql.sh)

for i in `mysql -e "show processlist" | awk '/Sleep/ {print $1}'` ; do mysql -e "KILL $i;"; done

# Create Cronjob
wget -O /root/scriptclaus/kill_sleeping_mysql.sh https://gitlab.com/brixly/file-dump/raw/master/scripts/kill_sleeping_mysql.sh
chmod 655 /root/scriptclaus/kill_sleeping_mysql.sh
echo "*/15 * * * * /bin/bash /root/scriptclaus/kill_sleeping_mysql.sh > /dev/null 2>&1" > /etc/cron.d/kill_sleeping_mysql
