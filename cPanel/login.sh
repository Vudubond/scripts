if [ "$#" -eq 0 ] ; then
        whmapi1 create_user_session user=root service=whostmgrd
elif [ "$#" -eq 1 ] ; then
        arg=$(echo $1)
        echo $1|grep '@'
        if [ $? -eq 0 ] ; then
                whmapi1 create_user_session user=$arg service=webmaild
        else
                echo $1|grep '\.'
                if [ $? -ne 0 ] ; then
                        whmapi1 create_user_session user=$arg service=cpaneld
                else
                        whmapi1 create_user_session user=$(/scripts/whoowns $arg) service=cpaneld
                fi
        fi
else
        echo "Invalid number of parameters"
fi
