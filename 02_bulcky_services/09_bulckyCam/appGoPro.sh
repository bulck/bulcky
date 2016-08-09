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
        echo "--> Getting media list at `date`"
        if [ "$GOPRO_VERSION" == "SESSION" ]; then
            /usr/bin/wakeonlan  -i 10.5.5.9 -p 9 $GOPRO_MAC
        fi

        i="0"
        error="1"
        while [ $i -lt 2 ]; do
            i=$[$i+1]
            ping -c 3 10.5.5.9 >/dev/null
            if [ $? -ne 0 ]; then
                ifdown wlan0
                sleep 2
                ifup wlan0
                sleep 2
            else
                error="0";
                break;
            fi
        done

        if [ $error -eq 0 ]; then
            /usr/bin/wget -q -O -  http://10.5.5.9/gp/gpMediaList
        fi
        echo "-----"
    ;;
    --takePhoto)
        i="0"
        error="1"

        exec 2>&1
        exec > >(logger -t "appGoPro : ")

        if [ "$GOPRO_VERSION" == "SESSION" ]; then
            /usr/bin/wakeonlan -i 10.5.5.9 -p 9 $GOPRO_MAC
        fi

        while [ $i -lt 2 ]; do
            i=$[$i+1]
            ping -c 3 10.5.5.9 >/dev/null
            if [ $? -ne 0 ]; then
                ifdown wlan0
                sleep 2
                ifup wlan0
                sleep 2
            else
                error="0";
                break;
            fi
        done

        if [ $error -eq 0 ]; then
            /usr/bin/wget -q -O - "http://10.5.5.9/gp/gpControl/setting/10/0" >/dev/null
            sleep 3
            /usr/bin/wget -q -O - "http://10.5.5.9/gp/gpControl/setting/21/0"
            sleep 3
            /usr/bin/wget -q -O - "http://10.5.5.9/gp/gpControl/setting/34/0"
            sleep 3
            /usr/bin/wget -q -O - "http://10.5.5.9/gp/gpControl/setting/19/0"
            sleep 3
            /usr/bin/wget -q -O - "http://10.5.5.9/gp/gpControl/setting/54/0"
            sleep 3
            /usr/bin/wget -q -O - " http://10.5.5.9/gp/gpControl/setting/50/0"
            sleep 3
            /usr/bin/wget -q -O - "http://10.5.5.9/gp/gpControl/setting/21/1"
            sleep 3
            /usr/bin/wget -q -O - "http://10.5.5.9/gp/gpControl/setting/22/0"
            sleep 3
            /usr/bin/wget -q -O - "http://10.5.5.9/gp/gpControl/setting/23/0"
            sleep 3
            wget -q -O - "http://10.5.5.9/gp/gpControl/command/sub_mode?mode=1&sub_mode=1"
            sleep 3
            wget -q -O - "http://10.5.5.9/gp/gpControl/setting/19/0"
            sleep 3
            /usr/bin/wget -q -O - "http://10.5.5.9/gp/gpControl/command/shutter?p=1" > /dev/null

            if [ $? -ne 0 ]; then
                exit 4
            else
                 echo "--> A new photo has been taken"
            fi
        fi
    ;;
    *) usage
   ;;
esac

exit 0

