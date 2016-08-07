#!/bin/bash

function usage {
    echo "$0 options:"
    echo "    --list : list media available"
    echo "    --takePhoto : take a photo"
    echo ""
    echo "Note: you have to fill the /etc/bulckyconf/gopro_cam.sh file"
    echo "      to enable this script"
    return 0
}



if [ ! -f /etc/bulckyconf/gopro_cam.conf ]; then
    exit 1
fi

. /etc/bulckyconf/gopro_cam.conf

if [ "$GOPRO_VERSION" == "" ] || [ "$GOPRO_MAC" == "" ]; then
    exit 2
fi

if [ "$1" == "" ]; then
    usage
fi


case "$1" in
    --list)  
        if [ "$GOPRO_VERSION" == "SESSION" ];
            /usr/bin/wakeonlan -i 10.5.5.9 -p 9 $GOPRO_MAC
        fi 

        /usr/bin/wget -q -O -  http://10.5.5.9:8080/gp/gpMediaList        
    ;;
    --takePhoto)  
        if [ "$GOPRO_VERSION" == "SESSION" ];
            /usr/bin/wakeonlan -i 10.5.5.9 -p 9 $GOPRO_MAC
        fi 
        /usr/bin/wget http://10.5.5.9/gp/gpControl/command/mode?p=1 -O -
        /usr/bin/wget http://10.5.5.9/gp/gpControl/command/shutter?p=1 -O -
    ;;
    *) usage
   ;;
esac

exit 0

