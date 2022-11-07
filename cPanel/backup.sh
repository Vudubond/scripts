# !/bin/bash

# Create a backup of a user account, and move this to their home directory
if [ "$#" -eq 0 ] ; then
        echo "Please specify the username you wish to Backup"
elif [ "$#" -eq 1 ] ; then
        arg=$(echo $1)
        echo $1|grep '@'
        if [ $? -eq 0 ] ; then
                /scripts/pkgacct $1 /home/$1/
                chmod 655 /home/$1/cpmove-$1.tar.gz
                chown $1:$1 /home/$1/cpmove-$1.tar.gz
                echo "Backup file created - /home/$1/cpmove-$1.tar.gz"
        fi
elif [ "$#" -eq 2 ] ; then
        arg=$(echo $1)
                /scripts/pkgacct $1 /var/www/html/
                chmod 655 /var/www/html/cpmove-$1.tar.gz
                echo "Backup file created - https://$(hostname)/cpmove-$1.tar.gz"
        #fi
else
        echo "Invalid number of parameters"
fi
