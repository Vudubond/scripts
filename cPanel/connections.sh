printf "\nSelf-Updating Script...\n"
wget -O /root/scriptclaus/connections.sh https://raw.githubusercontent.com/Vudubond/scripts/main/cPanel/connections.sh

printf "\nLSAPI Key Metrics:\n"
cat /etc/apache2/conf.d/lsapi.conf | grep "lsapi_criu "
cat /etc/apache2/conf.d/lsapi.conf | grep "lsapi_with_connection_pool " 
cat /etc/apache2/conf.d/lsapi.conf | grep "lsapi_backend_initial_start " 
cat /etc/apache2/conf.d/lsapi.conf | grep "lsapi_reset_criu_on_apache_restart " 
cat /etc/apache2/conf.d/lsapi.conf | grep "lsapi_backend_children " 
cat /etc/apache2/conf.d/lsapi.conf | grep "lsapi_terminate_backends_on_exit " 
cat /etc/apache2/conf.d/lsapi.conf | grep "lsapi_avoid_zombies " 

printf "\nMySQL Key Metrics:\n"
cat /etc/my.cnf | grep "sql-mode\|sql_mode"
cat /etc/my.cnf | grep "key-buffer-size\|key_buffer_size"
cat /etc/my.cnf | grep "query-cache-size\|query_cache_size"
cat /etc/my.cnf | grep "max-connections\|max_connections "
cat /etc/my.cnf | grep "innodb-buffer-pool-size\|innodb_buffer_pool_size"

printf "\nMySQL Governor is set to: "
cat /etc/container/mysql-governor.xml | grep lve | awk -F"\"" '{print $2}'

printf "\nCSF Deny List Length:\n"
cat /etc/csf/csf.deny | wc -l

printf "\nCurrent Load / Uptime:\n"
w

printf "\nConnections by Server on port 80/443 / Destination IP: \n"
netstat -alpn | grep ':80 \|:443 ' |grep -v 127.0.0.1|grep -v 0.0.0.0| awk '{print $5}' |awk -F: '{print $(NF-1)}' |sort | uniq -c | sort -n

printf "\nConnections Breakdown:"
netstat -tn|awk '{print $6}'|sort|uniq -c

printf "\nConnections by External IP:\n"
netstat -ntu |grep -v 127.0.0.1|grep -v 0.0.0.0 | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n | tail

printf "\nApache Domlogs by Size:\n"
ls -lathS /etc/apache2/logs/domlogs/ | head -5

printf "\nLVE Stats / 24h:\n"
lveinfo -d --period=1d --by-fault=any --show-columns="ID,From,To,CPUf,VMemF,EPf,PMemF,NprocF,IOf,IOPSf"

printf "\nLVE Stats for past 60 minutes - EP (See CPUf Column):\n"
lveinfo --by-fault=cpu --period=1h -d --limit=5 --show-columns=id,cpuf

printf "\nLVE Stats for past 60 minutes - EP (See EPf Column):\n"
lveinfo --by-fault=ep --period=1h -d --limit=5 --show-columns=id,epf

printf "\nLVE Stats for past 60 minutes - Memory Usage (See PMemF Column):\n"
lveinfo --by-fault=pmem --period=1h -d --limit=5 --show-columns=id,pmemf

printf "\nLVE Stats for past 60 minutes - IO Usage (See PMemF Column):\n"
lveinfo --by-fault=io --period=1h -d --limit=5 --show-columns=id,iof

printf "\n10 Highest rate-limited domains on Nginx: \n"
cat /var/log/nginx/error_log | grep limiting | awk -F"server: " '{print $2}' | awk -F"," '{print $1}' | sort | uniq -c | sort -n | tail -10

printf "\n10 Highest rate-limited requests on Nginx: \n"
cat /var/log/nginx/error_log | grep limiting | awk -F"request: " '{print $2}' | awk -F"," '{print $1}' | sort | uniq -c | sort -n | tail -10

printf "\n20 Highest Exim Senders: \n"
grep cwd /var/log/exim_mainlog | grep -v /var/spool | awk -F"cwd=" '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -n | tail -20

printf "\n20 Highest Cron Log Entries: \n"
cat /var/log/cron | awk -F"(" '{print $2}' | awk -F")" '{print $1}' | sort | uniq -c | sort -n | tail -20

printf "\n"
read -p "Do you want to check Consume per user? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
OUT=$(/usr/local/cpanel/bin/dcpumonview | grep -v Top | sed -e 's#<[^>]*># #g' | while read i ; do NF=`echo $i | awk {'print NF'}` ; if [[ "$NF" == "5" ]] ; then USER=`echo $i | awk {'print $1'}`; OWNER=`grep -e "^OWNER=" /var/cpanel/users/$USER | cut -d= -f2` ; echo "$OWNER $i"; fi ; done) ; (echo "USER CPU" ; echo "$OUT" | sort -nrk4 | awk '{printf "%s %s%\n",$2,$4}' | head -5) | column -t ;echo;(echo -e "USER MEMORY" ; echo "$OUT" | sort -nrk5 | awk '{printf "%s %s%\n",$2,$5}' | head -5) | column -t ;echo;(echo -e "USER MYSQL" ; echo "$OUT" | sort -nrk6 | awk '{printf "%s %s%\n",$2,$6}' | head -5) | column -t ;
fi

printf "\n"
read -p "Do you want to check the Apache domlogs for most frequent IP's (USE WITH CAUTION)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cat /etc/apache2/logs/domlogs/*/* | awk '{print $1}' | sort | uniq -c | sort -n | tail -20 > /tmp/freqips.txt
    printf "\n"
    cat /tmp/freqips.txt
    read -p "Do you want me to suspend the top 10 IP's? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        for ip in $(cat /tmp/freqips.txt | awk '{print $2}'); do imunify360-agent blacklist ip add $ip --scope group --comment "Large Connections in Domlogs - view_connections"; done;
    fi
fi

printf "\n"
read -p "Do you want to check for suspicious processes for NGINX SERVER Only? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    /opt/nDeploy/nDeploy_whm/abnormal_process_detector.cgi
fi

printf "\n"
read -p "Do you want to check Apache status via lynx? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    lynx http://localhost/whm-server-status
fi

printf "\n"
read -p "Do you want to check Litespeed status? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    curl -i -k --output - --netrc-file ~/.netrc https://localhost:7080/status?rpt=detail
fi

printf "\n"
read -p "Do you want to check Nginx status via lynx? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    lynx http://localhost/nginx_status
fi

printf "\n"
read -p "Do you want to check running MySQL processes? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    mysqladmin pr
fi

printf "\n"
read -p "Do you want to tail the logs? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    multitail /etc/apache2/logs/error_log /var/log/nginx/error_log /var/log/lfd.log /var/log/messages
fi

printf "\n"
read -p "Do you want to block most common IP's in TCP / UDP (Use with Caution)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for ip in $(grep TCP_IN /var/log/messages | awk -F"SRC=" '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -n | tail -20 | awk '{print $2}'); do csf -d $ip "Too many TCP_IN Entries in messages logs"; done;
    for ip in $(grep TCP_OUT /var/log/messages | awk -F"DST=" '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -n | tail -20 | awk '{print $2}'); do csf -d $ip "Too many TCP_OUT Entries in messages logs"; done;
fi

printf "\n"
read -p "Do you want to perform a full security analysis (CSI)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    wget -O /scripts/csi.py https://github.com/CpanelInc/tech-CSI/raw/master/csi.pl
    chmod 655 /scripts/csi.py
    /scripts/csi.py
fi

printf "\n"
read -p "Do you want to run a system status probe? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    wget -O /scripts/ssp https://github.com/CpanelInc/SSP/raw/master/ssp
    chmod 655 /scripts/ssp
    /scripts/ssp
fi
