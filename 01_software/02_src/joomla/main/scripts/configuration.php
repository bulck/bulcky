<?php

if (!isset($_SESSION)) {
    session_start();
}

require_once('main/libs/config.php');
require_once('main/libs/db_get_common.php');
require_once('main/libs/db_set_common.php');
require_once('main/libs/utilfunc.php');
require_once('main/libs/debug.php');
require_once('main/libs/utilfunc_sd_card.php');


// Compute page time loading for debug option
$start_load = getmicrotime();

// Language for the interface, using a SESSION variable and the function __('$msg') from utilfunc.php library to print messages
$main_error=array();
$main_info=array();

$_SESSION['LANG'] = get_current_lang();
$_SESSION['SHORTLANG'] = get_short_lang($_SESSION['LANG']);
__('LANG');

// ================= VARIABLES ================= //
$update_conf=false;

$pop_up_message="";
$pop_up_error_message="";

$submenu        = getvar("submenu",$main_error);
$version        = get_configuration("VERSION",$main_error);

// By default the expanded menu is the user interface menu
if((!isset($submenu))||(empty($submenu))) {
    if(isset($_SESSION['submenu'])) {
        $submenu=$_SESSION['submenu'];
        unset($_SESSION['submenu']);
    } else {
        $submenu="user_interface";
    }
} 

// Trying to find if a cultibox SD card is currently plugged and if it's the case, get the path to this SD card
if((!isset($sd_card))||(empty($sd_card))) {
   $hdd_list=array();
   $sd_card=get_sd_card($hdd_list);
   $new_arr=array();
   foreach($hdd_list as $hdd) {
        if(disk_total_space($hdd)<=2200000000) $new_arr[]=$hdd;

   }
   $hdd_list=$new_arr;
   sort($hdd_list);
}


//============================== GET OR SET CONFIGURATION PART ====================
//update_conf sert à définir si la configuration impacte la carte SD
$conf_arr = array();
$conf_arr["SHOW_POPUP"]             = array ("update_conf" => "0", "var" => "pop_up");
$conf_arr["CHECK_UPDATE"]           = array ("update_conf" => "0", "var" => "update");
$conf_arr["COLOR_COST_GRAPH"]       = array ("update_conf" => "0", "var" => "color_cost");
$conf_arr["RECORD_FREQUENCY"]       = array ("update_conf" => "1", "var" => "record_frequency");
$conf_arr["POWER_FREQUENCY"]        = array ("update_conf" => "1", "var" => "power_frequency");
$conf_arr["UPDATE_PLUGS_FREQUENCY"] = array ("update_conf" => "1", "var" => "update_frequency");
$conf_arr["NB_PLUGS"]               = array ("update_conf" => "0", "var" => "nb_plugs");
$conf_arr["SECOND_REGUL"]           = array ("update_conf" => "0", "var" => "second_regul");
$conf_arr["STATISTICS"]             = array ("update_conf" => "0", "var" => "stats");
$conf_arr["SHOW_COST"]              = array ("update_conf" => "0", "var" => "show_cost");
$conf_arr["ADVANCED_REGUL_OPTIONS"] = array ("update_conf" => "1", "var" => "advanced_regul");
$conf_arr["RTC_OFFSET"]             = array ("update_conf" => "1", "var" => "rtc_offset");
$conf_arr["RESET_MINMAX"]           = array ("update_conf" => "1", "var" => "reset_minmax");
$conf_arr["ALARM_VALUE"]            = array ("update_conf" => "1", "var" => "alarm_value");
$conf_arr["VERSION"]                = array ("update_conf" => "0", "var" => "version");
$conf_arr["WIFI_ENABLE"]            = array ("update_conf" => "1", "var" => "wifi_enable");
$conf_arr["WIFI_SSID"]            = array ("update_conf" => "1", "var" => "wifi_ssid");
$conf_arr["WIFI_PASSWORD"]            = array ("update_conf" => "1", "var" => "wifi_password");
$conf_arr["WIFI_IP"]            = array ("update_conf" => "1", "var" => "wifi_ip");
$conf_arr["WIFI_IP_MANUAL"]            = array ("update_conf" => "1", "var" => "wifi_ip_manual");
$conf_arr["WIFI_KEY_TYPE"]            = array ("update_conf" => "1", "var" => "wifi_key_type");
$conf_arr["WIFI_MANUAL"]            = array ("update_conf" => "1", "var" => "wifi_manual");


foreach ($conf_arr as $key => $value) {
    ${$value['var']} = get_configuration($key,$main_error);
}


// Include in html pop up and message
include('main/templates/post_script.php');

//Display the configuration template
include('main/templates/configuration.html');

//Compute time loading for debug option
$end_load = getmicrotime();

if($GLOBALS['DEBUG_TRACE']) {
    echo __('GENERATE_TIME').": ".round($end_load-$start_load, 3) ." secondes.<br />";
    echo "---------------------------------------";
    aff_variables();
    echo "---------------------------------------<br />";
    memory_stat();
}




?>
