<?php


$iface=array();

if(is_file("/tmp/interfaces")) {
    exec("sudo /bin/cp /etc/network/interfaces /etc/network/interfaces.SAVE");
    exec("sudo /bin/mv /tmp/interfaces /etc/network/interfaces");
    exec("sudo /bin/chmod 644 /etc/network/interfaces*");
    exec("sudo /sbin/ifup -a --no-act >/dev/null 2>&1 ; echo \"$?\"",$output,$err);
    if((count($output)==1)&&(strcmp($output[0],"0")==0)) {
        sleep(2);
        exec("sudo /etc/init.d/networking restart");
        sleep(3);
        exec("ip addr show eth0 | awk '/inet/ {print $2}' | cut -d/ -f1",$iface['ETH'],$err);
        exec("ip addr show wlan0 | awk '/inet/ {print $2}' | cut -d/ -f1",$iface['WLAN'],$err);
        echo json_encode("1");
    } else {
        exec("sudo /bin/mv /etc/network/interfaces.SAVE /etc/network/interfaces");
        echo json_encode("0");
    }
} else {
    echo json_encode("0");
}

?>
