#!/bin/sh
path="/var/log/server-status"
ddd=`date +%Y-%m-%d`
logfile=$path/$ddd/logfile.txt

### Check if direction to store log exists, if doesn't - create it ###
if [ ! -d $path/$ddd ]; then
    mkdir $path/$ddd
fi

### Add blank line and head 5 of top on every script run ###
echo >> $logfile
echo "!-------------------------------------------- top 20" >> $logfile
COLUMNS=512 /usr/bin/top -cSb -n 1 | head -15               >> $logfile

echo "!---------------------------------------- vmstat 1 4" >> $logfile
/usr/bin/vmstat 1 4                                         >> $logfile

echo "!------------------------------------------ uname -r" >> $logfile
uname -r                                                    >> $logfile

echo "!--------------------------------------------- df -h" >> $logfile
df -h                                                       >> $logfile

echo "!------------------------------------------- free -m" >> $logfile
/usr/bin/free -mh                                           >> $logfile

echo "!-------------------------------------------- mdstat" >> $logfile
cat /proc/mdstat                                            >> $logfile

### Check if load average is greater or equal 16 if it does - collect needed stats ###

if [ `cat /proc/loadavg | /usr/bin/awk '{ print $1 }' | /usr/bin/cut -d. -f1-1` -ge 24 ]
then

### INSERT custom gathering commands after this line, they are executed only when LA is above 7

###



echo "!------------------------------------------- meminfo" >> $logfile
awk '$3=="kB"{$2=$2/1024;$3="MB"} 1' /proc/meminfo | column -t >> $logfile


echo "!---------------------------------- netstat by state" >> $logfile
/bin/netstat -an|awk '/tcp/ {print $6}'|sort|uniq -c        >> $logfile

echo "!---------------------------------- processes by mem" >> $logfile
ps -e -orss=,args= |awk '{print $1 " " $2 }'| awk '{tot[$2]+=$1;count[$2]++} END {for (i in tot) {print tot[i],i,count[i]}}' | sort -n | tail -n 10 | sort -nr | awk '{ hr=$1/1024; printf("%13.2fM", hr); print "\t" $2 }' >> $logfile

echo "!--------------------- process by memory usage (RSS)" >> $logfile
ps -axu --sort -rss | awk 'NR>1 {$5=int($5/1024)"M";}{ print;}' | awk 'NR>1 {$6=int($6/1024)"M";}{ print;}' | head -10 >> $logfile

echo "!------------------------------------- iotop -b -n 3" >> $logfile
#/usr/sbin/iotop -b -o -n 3                                  >> $logfile

echo "!--------------------------------------- perf record" >> $logfile

#/usr/bin/perf record -o $path/$ddd/perf-record.`date +%H-%M`.txt -g -a sleep 3
fi

### Do something more if load average does not match threshold ###

### Remove directories older then 5 days ###
cd $path
ls -1r|grep -v getstatus|sed -n '5,$p'|xargs -i rm -rf "{}"
