<?php

    require_once('../../libs/config.php');

    if((isset($_GET['width'])) && (!empty($_GET['width']))) {
        $width=$_GET['width'];
    } else {
        $width=640;
    }


    if((isset($_GET['height'])) && (!empty($_GET['height']))) {
        $action=$_GET['height'];
    } else {
        $height=480;
    }

    exec("ls /dev/video* 2>/dev/null",$output,$err);
    if(count($output)==0) {
       echo json_encode("1");
    } else {
        exec("sudo fswebcam -p YUYV -r ".$width."x".$height." --no-banner ".$GLOBALS['BASE_PATH']."/tmp/webcam.jpg 2>&1",$test,$err);
        foreach($test as $line) {
            if(strpos($line, "Unable to find a compatible palette format")!==false) {
                exec("sudo fswebcam -r ".$width."x".$height." --no-banner ".$GLOBALS['BASE_PATH']."/tmp/webcam.jpg",$test,$err);
                break;
            }
        }
        echo json_encode("0");
    }
?>
