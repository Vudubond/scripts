# !/bin/bash
if [ "$#" -eq 0 ] ; then
        echo "Please specify the username you wish to Boost"
elif [ "$#" -eq 1 ] ; then
        arg=$(echo $1)
        echo $1|grep '@'
        if [ $? -eq 0 ] ; then
                whmapi1 create_user_session user=$arg service=webmaild
        else
                lvectl set-user $arg --speed=400% --pmem=4G --ep=60 --io=61440
                dbctl set $arg --cpu=600,500,400,300 --read=60,40,20,10 --write=60,40,20,10
                echo "User $arg has been Boosted"
                #fi
        fi
elif [ "$#" -eq 2 ] ; then
        arg=$(echo $1)
        lvectl set-user $arg --default=all
        dbctl set $arg --cpu=300,270,240,200 --read=30,20,10,5 --write=30,20,10,5 
        echo "Boost removed for $arg"
        #fi
else
        echo "Invalid number of parameters"
fi
