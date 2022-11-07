echo -e "Updating Script: \n"
wget -O /root/scriptclaus/clean_server.sh https://raw.githubusercontent.com/Vudubond/scripts/main/cPanel/clean_server.sh
echo -e "Cleaning Exim Mail Queue: \n"
exim -bp | grep \< | awk '{print $3}' | xargs exim -Mrm
echo -e "Cleaning cPanel Backups: \n"
rm -fv /home/*/backup-*.tar.gz
rm -fv /home/*/cpmove-*.tar.gz
echo -e "Cleaning Cpanel_* Files / Temps: \n"
rm -fv /home/*/tmp/Cpanel_*
echo -e "Cleaning Old Logs: \n"
find /var/log -name "*.gz" -print -delete
find /var/log/server-status/ -mtime +1 -type d -exec rm -Rf {} \;
rm -fv /var/log/exim_mainlog-*
rm -fv /var/log/exim_paniclog-*
rm -fv /var/log/exim_rejectlog-*
rm -fv /var/log/lve-stats.log-*
rm -fv /usr/local/jetapps/usr/jetbackup5/downloads/*
echo -e "Cleaning /usr/local/src: \n"
rm -fv /usr/local/src/*
echo -e "Cleaning Softaculous Backups: \n"
rm -rfv /home/*/softaculous_backups
echo -e "Cleaning Updraft / BackupBuddy Backups: \n"
rm -rfv /home/*/public_html/wp-content/updraft/*.zip
rm -rfv /home/*/backupbuddy_backups/*
rm -rfv /home/*/com_akeeba/backup/*
echo -e "Cleaning cPanel Trash Backups: \n"
rm -rfv /home/*/.trash/*
echo -e "Cleaning Additional files and Error Logs: \n"
find /home/ -type f \( -iname duplicati*.aes -o -iname *.wpress -o -iname *.rar -o -iname *.iso -o -iname *.exe -o -iname *.xen -o -iname *.7z -o -iname *.tar -o -iname *.tar.gz -o -iname *.mkv -o -iname *.avi -o -iname *.pbo -o -iname *.VOB -o -iname error_log -o -iname *_backup -o -iname backup*.zip -o -iname Backup*.zip -o -iname php_error_log -o -iname *.zi -o -iname public_html.zip -o -iname wp-admin.zip -o -iname mail.zip -o -iname email.zip -o -iname *.h264 -o -iname *.zi -o -iname *zst \) -print -delete
echo -e "Removing JetBackup Downloads"
rm -Rf /usr/local/jetapps/usr/jetbackup5/downloads/*
echo -e "Cleaning Junk Mail: \n"
MAILDIRS=$(find /home/*/mail/*/* -maxdepth 0 -type d)
INBOXFOLDERS=(.Trash .Junk .Spam .Low\ Priority .cPanel\ Reports)
for basedir in $MAILDIRS; do
for ((i = 0; i < ${#INBOXFOLDERS[*]}; i++)); do
for dir in cur new; do
[ -e “$basedir/${INBOXFOLDERS[$i]}/$dir” ] && (
echo “Processing $basedir/${INBOXFOLDERS[$i]}/$dir…”
find “$basedir/${INBOXFOLDERS[$i]}/$dir/” -type f -mtime +30 -delete
)
done
done
done
/scripts/generate_maildirsize -–allaccounts --confirm --verbose
find /home/ -type d \( -iname backwpup-*-backup -o -iname wpbackitup_backups -o -iname autoptimize \) -print -exec rm -rf {} \;
