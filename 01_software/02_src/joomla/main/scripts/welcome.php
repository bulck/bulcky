<?php


if (!isset($_SESSION)) {
	session_start();
}

// Compute page time loading for debug option
$start_load = getmicrotime();


/* Libraries requiered: 
        db_common.php : manage database requests
        utilfunc.php  : manage variables and files manipulations
*/
require_once('main/libs/config.php');
require_once('main/libs/db_common.php');
require_once('main/libs/utilfunc.php');


// Language for the interface, using a SESSION variable and the function __('$msg') from utilfunc.php library to print messages
$main_error=array();
$main_info=array();
$_SESSION['LANG'] = get_current_lang();
$_SESSION['SHORTLANG'] = get_short_lang($_SESSION['LANG']);
$version=get_configuration("VERSION",$main_error);
__('LANG');


// ================= VARIABLES ================= //
$program="";
$sd_card="";
$update=get_configuration("CHECK_UPDATE",$main_error);
$wizard=true;
$nb_plugs = get_configuration("NB_PLUGS",$main_error);
$stats=get_configuration("STATISTICS",$main_error);
$pop_up_message="";
$pop_up_error_message="";
$pop_up=get_configuration("SHOW_POPUP",$main_error);
$browser=array();
$compat=true;
$notes=array();



$browser=get_browser_infos();
if(count($browser)>0) {
        $compat=check_browser_compat($browser); 
}

//If programs configured by user is empty, display the wizard interface link
if(isset($nb_plugs)&&(!empty($nb_plugs))) {
    if(check_programs($nb_plugs)) {
        $wizard=false;  
    }
}


// Trying to find if a cultibox SD card is currently plugged and if it's the case, get the path to this SD card
if((!isset($sd_card))||(empty($sd_card))) {
        $sd_card=get_sd_card();
}

// If a cultibox SD card is plugged, manage some administrators operations: check the firmaware and log.txt files, check if 'programs' are up tp date...
if((!empty($sd_card))&&(isset($sd_card))) {
    $conf_uptodate=true;
    if(check_sd_card($sd_card)) {
        $program=create_program_from_database($main_error);

        if(!compare_program($program,$sd_card)) {
            $conf_uptodate=false;
            save_program_on_sd($sd_card,$program,$main_error);
        }

        if(check_and_copy_firm($sd_card,$main_error)) {
            $conf_uptodate=false;
        }

        if(!compare_pluga($sd_card)) {
            $conf_uptodate=false;
            write_pluga($sd_card,$main_error);
        }


        $plugconf=create_plugconf_from_database($GLOBALS['NB_MAX_PLUG'],$main_error);
        if(count($plugconf)>0) {
            if(!compare_plugconf($plugconf,$sd_card)) {
                $conf_uptodate=false;
                write_plugconf($plugconf,$sd_card);
            }
        }

        if(!check_and_copy_log($sd_card)) {
            $main_error[]=__('ERROR_COPY_TPL');
        }

        
        if(!check_and_copy_index($sd_card)) {
            $main_error[]=__('ERROR_COPY_FILE');
        }


        $recordfrequency = get_configuration("RECORD_FREQUENCY",$main_error);
        $powerfrequency = get_configuration("POWER_FREQUENCY",$main_error);
        $updatefrequency = get_configuration("UPDATE_PLUGS_FREQUENCY",$main_error);
        $alarmenable = get_configuration("ALARM_ACTIV",$main_error);
        $alarmvalue = get_configuration("ALARM_VALUE",$main_error);
        if("$updatefrequency"=="-1") {
            $updatefrequency="0";
        }

        if(!compare_sd_conf_file($sd_card,$recordfrequency,$updatefrequency,$powerfrequency,$alarmenable,$alarmvalue)) {
            $conf_uptodate=false;
            write_sd_conf_file($sd_card,$recordfrequency,$updatefrequency,$powerfrequency,"$alarmenable","$alarmvalue",$main_error);
        }

        if(!$conf_uptodate) {
            $main_info[]=__('UPDATED_PROGRAM');
            $pop_up_message=$pop_up_message.popup_message(__('UPDATED_PROGRAM'));
            set_historic_value(__('UPDATED_PROGRAM')." (".__('WELCOME_PAGE').")","histo_info",$main_error);
        }

        $main_info[]=__('INFO_SD_CARD').": $sd_card";
    } else {
        $main_error[]=__('ERROR_WRITE_PROGRAM');
    }
} else {
        $main_error[]=__('ERROR_SD_CARD');
}


// The informations part to send statistics to debug the cultibox: if the 'STATISTICS' variable into the configuration table from the database is set to 'True'
$informations = Array();
$informations["cbx_id"]="";
$informations["firm_version"]="";
$informations["id_computer"]=php_uname("a");
$informations["log"]="";


if((!empty($sd_card))&&(isset($sd_card))) {
    find_informations("$sd_card/log.txt",$informations);
    if(strcmp($informations["log"],"")!=0) {
        clean_log_file("$sd_card/log.txt");
    }
}

if((isset($stats))&&(!empty($stats))&&(strcmp("$stats","True")==0)) {
    if(strcmp($informations["cbx_id"],"")==0) {
        $informations["cbx_id"]=get_informations("cbx_id");
    } else {
        insert_informations("cbx_id",$informations["cbx_id"]);
    }

    if(strcmp($informations["firm_version"],"")==0) {
        $informations["firm_version"]=get_informations("firm_version");
    } else {
        insert_informations("firm_version",$informations["firm_version"]);
    }

    if(strcmp($informations["log"],"")!=0) {
        insert_informations("log",$informations["log"]);
    } else {
        $informations["log"]="NA";
    }

    $user_agent = getenv("HTTP_USER_AGENT");
}


// Check for update availables. If an update is availabe, the link to this update is displayed with the informations div
if(strcmp("$update","True")==0) {
    if($sock = @fsockopen("${GLOBALS['REMOTE_SITE']}", 80)) {
      $ret=array();
      check_update_available($version,$ret,$main_error);
      foreach($ret as $file) {
                $main_info[]=__('INFO_UPDATE_AVAILABLE')." <a class='download' href=".$file[2].">".$file[1]."</a>";
      }
   } else {
    $main_error[]=__('ERROR_REMOTE_SITE');
   }
}

get_notes($notes,$_SESSION['LANG'],$main_error);

//Display the welcome template
include('main/templates/welcome.html');

//Compute time loading for debug option
$end_load = getmicrotime();

if($GLOBALS['DEBUG_TRACE']) {
    echo __('GENERATE_TIME').": ".round($end_load-$start_load, 3) ." s.<br />";
    echo "---------------------------------------";
    aff_variables();
    echo "---------------------------------------<br />";
    memory_stat();
}


?>
