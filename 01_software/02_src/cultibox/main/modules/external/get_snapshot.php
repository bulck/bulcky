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


    exec("sudo fswebcam -r ".$width."x".$height." --no-banner ".$GLOBALS['BASE_PATH']."/tmp/webcam.jpg",$output,$err);

?>
