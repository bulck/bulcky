<?php

require_once('../libs/utilfunc.php');
require_once('../libs/db_common.php');
require_once('../libs/config.php');

if((isset($_GET['hdd']))&&(!empty($_GET['hdd']))) {
    $path=$_GET['hdd'];
}


if((isset($_GET['progress']))&&(!empty($_GET['progress']))) {
    $progress=$_GET['progress'];
}

if((!isset($path))||(empty($path))) {
    echo -1;
    //set_historic_value(__('ERROR_FORMAT_SD_CARD')." (".__('CONFIGURATION_PAGE').")","histo_error",$main_error);
} else {
   if(check_sd_card($path)) {
        if((!isset($progress))||(empty($progress))) {
            $progress=0;
        }

        $logs="$path/logs";
        $cnf="$path/cnf";

        if(strcmp("$progress","0")==0) {
            if(!is_dir($logs)) mkdir("$logs");
            if(!is_dir($cnf)) mkdir("$cnf");

            if(!copy("../../tmp/cnf/cnt","$cnf/cnt")) {
                echo -1;
                return 0;
            }

            if(!copy("../../tmp/cnf/emetteur.hex","$cnf/emetteur.hex")) {
                echo -1;
                return 0;
            }


             //Copiyng firmware:
            check_and_copy_firm($path);

            //Creating pluga file:
            if(!write_pluga($path,$out)) {
                    echo -1;
                    return 0;
            }


            //Creating conf file:
            $update_frequency = get_configuration("UPDATE_PLUGS_FREQUENCY",$out);
            if("$update_frequency"=="-1") $update_frequency="0";
            if(!write_sd_conf_file($path,get_configuration("RECORD_FREQUENCY",$out),"$update_frequency",get_configuration("POWER_FREQUENCY",$out),get_configuration("ALARM_ACTIV",$out),get_configuration("ALARM_VALUE",$out),get_configuration("ALARM_SENSO",$out),get_configuration("ALARM_SENSS",$out),$out)) {
                echo -1;
                return 0;
            }


            // Creating log.txt file:
            if(!check_and_copy_log($path,$out)) {
                echo -1;
                return 0;
            }


            // Creating programs:
            if(!copy("../templates/data/empty_file.tpl","$path/plugv")) {
                echo -1;
                return 0;
            }

            $program=create_program_from_database($out);
            if(!save_program_on_sd($path,$program,$out)) {
                echo -1;
                return 0;
            }


            //Create plugXX files:
            $plugconf=create_plugconf_from_database($GLOBALS['NB_MAX_PLUG'],$out);
            if(count($plugconf)>0) {
                if(!write_plugconf($plugconf,$path,$out)) {
                    echo -1;
                    return 0;
                }
            }

            //Copying cultibox icon:
            if(!copy("../../tmp/cultibox.ico","$path/cultibox.ico")) {
                echo -1;
                return 0;
            }

            //Copying cultibox homepage:
            if(!copy("../../tmp/cultibox.html","$path/cultibox.html")) {
                echo -1;
                return 0;
            }
            echo 1;
    } else {
            for($j=1;$j<=31;$j++) {
                    if(strlen($progress)<2) {
                        $month="0".$progress;
                    } else {
                        $month="$progress";
                    }

                    if(strlen($j)<2) {
                        $day="0".$j;
                    } else {
                        $day="$j";
                    }

                    if(!is_dir("$logs/$month")) {
                        mkdir("$logs/$month");
                    }

                    //Restore log and power files:
                    if(is_file("$logs/$month/$day")) {
                        if(filesize("$logs/$month/$day")!=filesize("../templates/data/empty_file_big.tpl")) {
                            if(!clean_log_file("$logs/$month/$day")) {
                                echo -1;
                                return 0;
                            }
                        }
                    } else {
                        if(!clean_log_file("$logs/$month/$day")) {
                            echo -1;
                            return 0;
                        }
                    }


                    if(is_file("$logs/$month/pwr_$day")) {
                        if(filesize("$logs/$month/pwr_$day")!=filesize("../templates/data/empty_file_big.tpl")) {
                            if(!clean_log_file("$logs/$month/pwr_$day")) {
                                echo -1;
                                return 0;
                            }
                        }
                    } else {
                        if(!clean_log_file("$logs/$month/pwr_$day")) {
                            echo -1;
                            return 0;
                        }
                    }
            }
            if($progress==12) {
                //set_historic_value(__('VALID_RESET_SD')." (".__('CONFIGURATION_PAGE').")","histo_info",$main_error);
                echo 100;
            } else {
                echo $progress+1;
            }
    }
  }
}

?>