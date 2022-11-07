printf "\nSuspended Accounts with the 'transferred' status: \n"
grep -r "User transferred to another server" /var/cpanel/suspended/

printf "\n"
read -p "Do you want to delete these accounts? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for user in $(grep -r "User transferred to another server" /var/cpanel/suspended/ | awk -F":" '{print $1}' | awk -F"/" '{print $5}'); do /scripts/removeacct --force --keepdns $user; done;
    printf "\nThe accounts are now being removed in a screen session"
fi
