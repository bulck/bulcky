alias bpilog='tail -f /var/log/bulcky/bulckypi.log'
alias bpislog='tail -f /var/log/bulcky/bulckypi-service.log'
alias bpireload='/etc/init.d/bulckypi force-reload'
alias bpirestart='/etc/init.d/bulckypi restart'
alias bpimysql='mysql -u bulcky -pbulcky bulcky '
alias bpirootsql='mysql -u root -pbulcky bulcky '
alias bpiupdate='bash -x /etc/cron.daily/bulcky --now --manual'

function bpiwget {
    echo "password:"
    read -s PASSWORD
    wget --user=root --password=$PASSWORD -O -
}

function bpisynconf {
    echo "password:"
    read -s PASSWORD
    wget --password=$PASSWORD --user=root http://localhost/bulcky/main/modules/external/sync_conf.php -O -
}

function bpicreateconf {
    echo "password:"
    read -s PASSWORD
    wget --password=$PASSWORD --user=root http://localhost/bulcky/main/modules/external/check_and_update_sd.php?sd_card=/etc/bulckypi/conf_tmp -O -
}

function bpirsensor { 
    tclsh /opt/bulckypi/bulckyPi/get.tcl serverAcqSensor localhost "::sensor($1,value)"
}

function bpirplug {
    tclsh /opt/bulckypi/bulckyPi/get.tcl serverPlugUpdate localhost "::plug($1,value)"
}

function bpisplug {
    tclsh /opt/bulckypi/bulckyPi/set.tcl serverPlugUpdate localhost $*
}

function bpiversion {
    for PACKAGE in bulckypi bulckyface bulckyraz bulckytime bulckydoc bulckycam bulckyconf
    do
        version=$(dpkg -s $PACKAGE 2>/dev/null|grep Version)
        echo "$PACKAGE : $version"
    done
}
