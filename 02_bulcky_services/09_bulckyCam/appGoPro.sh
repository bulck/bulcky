#!/bin/bash

function usage {
    echo "$0 options:"
    echo "    --list : list media available"
    echo "    --takePhoto : take a photo"
    echo ""
    echo "Note: you have to fill the /etc/bulckycam/appGoPro.conf file"
    echo "      to enable this script"
    return 0
}



if [ ! -f /etc/bulckycam/appGoPro.conf ]; then
    exit 1
fi

. /etc/bulckycam/appGoPro.conf

if [ "$GOPRO_VERSION" == "" ] || [ "$GOPRO_MAC" == "" ]; then
    exit 2
fi

if [ "$1" == "" ]; then
    usage
    exit 3
fi


case "$1" in
    --list)  
        if [ "$GOPRO_VERSION" == "SESSION" ]; then
            /usr/bin/wakeonlan -i 10.5.5.9 -p 9 $GOPRO_MAC
        fi 
        /usr/bin/wget -q -O -  http://10.5.5.9:8080/gp/gpMediaList        
    ;;
     --takePhoto)  
        i="0"
        error="0"

        while [ $i -lt 2 ]; do
            if [ "$GOPRO_VERSION" == "SESSION" ]; then
                /usr/bin/wakeonlan -i 10.5.5.9 -p 9 $GOPRO_MAC
            fi  

            /usr/bin/wget -q http://10.5.5.9/gp/gpControl/command/mode?p=1 -O - >/dev/null
            if [ $? -eq 0 ]; then
                /usr/bin/wget -q http://10.5.5.9/gp/gpControl/command/shutter?p=1 -O - >/dev/null
                if [ $? -ne 0 ]; then
                    error="1"
                else
                    echo "--> A new photo has been taken"
                    exit 0
                fi
            else
                error="1" 
            fi

            if [ "$error" == "1" ]; then
                error="0"
                sudo /sbin/ifdown wlan0
                sleep 2
                sudo /sbin/ifup wlan0
            fi

            i=$[$i+1]
        done
    ;;
    *) usage
   ;;
esac

exit 0
