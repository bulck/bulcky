<?php 

    $session_id = $_GET['session_id'];
    if (!isset($_SESSION)) {
        session_id($session_id);
        session_start();
    }

    // Include libraries
    if (file_exists('../../libs/db_get_common.php') === TRUE)
    {
        // Script call by Ajax
        require_once('../../libs/config.php');
        require_once('../../libs/db_get_common.php');
        require_once('../../libs/db_set_common.php');
        require_once('../../libs/utilfunc.php');
        require_once('../../libs/utilfunc_sd_card.php');
        require_once('../../libs/debug.php');
    }

    if(empty($_GET['value'])) {
        insert_configuration(strtoupper($_GET['variable']),"",$main_error);
    } else {
        // Save configuration
        insert_configuration(strtoupper($_GET['variable']),$_GET['value'],$main_error);
    }

    //Special configuration:
    switch(strtoupper($_GET['variable'])) {
        case 'SHOW_COST': configure_menu("cost",$_GET['value']);
                     break;
        case 'WIFI': configure_menu("wifi",$_GET['value']);
                     break;
    }

    // If update conf is defined, update sd configuration
    if ($_GET['updateConf'] != "undefined") {
        // search sd card
        $sd_card = get_sd_card();
        
        // Update conf file
        update_sd_conf_file($sd_card, $_GET['variable'],$_GET['value'],$main_error);
    }
    
    if(count($main_error)>0) {
        foreach($main_error as $error) {
            echo json_encode($error);
        }
    }

    echo json_encode("");
?>
