<?php

if (!isset($_SESSION)) {
	session_start();
}


require_once('main/libs/config.php');
require_once('main/libs/db_common.php');
require_once('main/libs/utilfunc.php');

$lang=get_configuration("LANG",$error);
set_lang($lang);
$_SESSION['LANG'] = get_current_lang();
__('LANG');

$error="";
$ret_plug=array();
$info="";
$finish=getvar('finish');
$info_plug=array();
$nb_plugs=get_configuration("NB_PLUGS",$error);
$selected_plug=getvar('selected_plug');
$next_plug=getvar('next_plug');

if((empty($selected_plug))||(!isset($selected_plug))) {
     $selected_plug=1;
}



$chinfo=true;
$chtime="";
$pop_up_message="";
$pop_up_error_message="";

if(!isset($pop_up)) {
        $pop_up = get_configuration("SHOW_POPUP",$error);
}


for($i=0;$i<=$nb_plugs;$i++) {
        $info_plug[]="";
        $ret_plug[]="";
}

$step=getvar('step');
$next=getvar('next');
$previous=getvar('previous');
$start_time="00:00:00";
$end_time="00:00:00";
$plug_type=getvar('plug_type');
$value_program=getvar('value_program');

if((empty($plug_type))||(!isset($plug_type))) {
	$plug_type=get_plug_conf("PLUG_TYPE",$selected_plug,$error); 
}


if((empty($value_program))||(!isset($value_program))) {
       $value_program="0.0";
}




if(((isset($finish))&&(!empty($finish)))||((isset($next_plug))&&(!empty($next_plug)))) {
        $program=getvar('program');

	if((isset($program))&&(!empty($program))) {
           if("$selected_plug"=="1") {
		$value_program="99.9";
		$plug_type="lamp";
                $start_time=getvar('start_time');
                $end_time=getvar('end_time');
           } else {
                $value_program=getvar('value_program');
                $plug_type=getvar('plug_type');
                $start_time=getvar('start_time');
                $end_time=getvar('end_time');
           }


              	$chtime=check_times($start_time,$end_time,$error); 
		if((isset($error))&&(!empty($error))) {
                           $pop_up_error_message=clean_popup_message($error);
                }
		//$chval=check_format_values_program($value_program);
		$chval=true;
	
                if(($chtime)&&($chval)) {
                        if($chtime==2) {
				$prog[]= array(
      					"start_time" => "$start_time",
                			"end_time" => "23:59:59",
                			"value_program" => "$value_program",
					"selected_plug" => "$selected_plug",
					"plug_type" => "$plug_type"
   				);

				 $prog[]= array(
                                        "start_time" => "00:00:00",
                                        "end_time" => "$end_time",
                                        "value_program" => "$value_program",
                                        "selected_plug" => "$selected_plug",
					"plug_type" => "$plug_type"
                                ); 
                        } else {
				$prog[]= array(
                                        "start_time" => "$start_time",
                                        "end_time" => "$end_time",
                                        "value_program" => "$value_program",
                                        "selected_plug" => "$selected_plug",
					"plug_type" => "$plug_type"
                                );
                        }


			clean_program($selected_plug,$error);	
                        foreach($prog as $val) {	
                                if(insert_program($val["selected_plug"],$val["start_time"],$val["end_time"],$val["value_program"],$error)) {
				       insert_program($val["selected_plug"],$val["start_time"],$val["end_time"],$val["value_program"],$error);
                                       if($chinfo) {
                                          $chinfo=true;
                                       }
				       insert_plug_conf("PLUG_TYPE",$val["selected_plug"],$val["plug_type"],$error);
                                } else {
					$chinfo=false;
					unset($finish);
                                }
                       }

		      if($chinfo) {
                           if(($selected_plug==$nb_plugs)||((isset($finish))&&(!empty($finish)))) {
                                header('Location: programs');	
                           }
			}
                } 
        }
        if((isset($next_plug))&&(!empty($next_plug))) {
			$selected_plug=$selected_plug+1;
			$step=1;
        }
        
}

$info=$info.__('WIZARD_DISABLE_FUNCTION');

if((!isset($step))||(empty($step))||(!is_numeric($step))||($step<0)) {
	$step=1;
} else if((isset($next))&&(!empty($next))) {
	$step=$step+1;	
} else if((isset($previous))&&(!empty($previous))) {
	$step=$step-1;
}

include('main/templates/wizard.html');

?>
