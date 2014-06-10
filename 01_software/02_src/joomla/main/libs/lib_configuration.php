<?php

namespace configuration {

// {{{ update_db()
// ROLE update dabase
// RET none
function check_db() {

    // Define columns of the calendar table
    $conf_index_col = array();
    $conf_index_col["id"]                   = array ( 'Field' => "id", 'Type' => "int(11)");
    $conf_index_col["CHECK_UPDATE"]         = array ( 'Field' => "CHECK_UPDATE", 'Type' => "varchar(5)");
    $conf_index_col["VERSION"]              = array ( 'Field' => "VERSION", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_HUMIDITY_GRAPH"] = array ( 'Field' => "COLOR_HUMIDITY_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_ORP_GRAPH"]      = array ( 'Field' => "COLOR_ORP_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_OD_GRAPH"]       = array ( 'Field' => "COLOR_OD_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_EC_GRAPH"]       = array ( 'Field' => "COLOR_EC_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_PH_GRAPH"]       = array ( 'Field' => "COLOR_PH_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_LEVEL_GRAPH"]    = array ( 'Field' => "COLOR_LEVEL_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_WATER_GRAPH"]    = array ( 'Field' => "COLOR_WATER_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_TEMPERATURE_GRAPH"] = array ( 'Field' => "COLOR_TEMPERATURE_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_POWER_GRAPH"]    = array ( 'Field' => "COLOR_POWER_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_COST_GRAPH"]     = array ( 'Field' => "COLOR_COST_GRAPH", 'Type' => "varchar(30)");
    $conf_index_col["COLOR_PROGRAM_GRAPH"]  = array ( 'Field' => "COLOR_PROGRAM_GRAPH", 'Type' => "varchar(30)", 'default_value' => "red");
    $conf_index_col["RECORD_FREQUENCY"]     = array ( 'Field' => "RECORD_FREQUENCY", 'Type' => "int(11)");
    $conf_index_col["POWER_FREQUENCY"]      = array ( 'Field' => "POWER_FREQUENCY", 'Type' => "int(11)");
    $conf_index_col["NB_PLUGS"]             = array ( 'Field' => "NB_PLUGS", 'Type' => "int(11)");
    $conf_index_col["UPDATE_PLUGS_FREQUENCY"] = array ( 'Field' => "UPDATE_PLUGS_FREQUENCY", 'Type' => "int(20)");
    $conf_index_col["SHOW_POPUP"]           = array ( 'Field' => "SHOW_POPUP", 'Type' => "varchar(5)");
    $conf_index_col["ALARM_ACTIV"]          = array ( 'Field' => "ALARM_ACTIV", 'Type' => "varchar(4)");
    $conf_index_col["ALARM_VALUE"]          = array ( 'Field' => "ALARM_VALUE", 'Type' => "varchar(5)");
    $conf_index_col["COST_PRICE"]           = array ( 'Field' => "COST_PRICE", 'Type' => "decimal(6,4)");
    $conf_index_col["COST_PRICE_HP"]        = array ( 'Field' => "COST_PRICE_HP", 'Type' => "decimal(6,4)");
    $conf_index_col["COST_PRICE_HC"]        = array ( 'Field' => "COST_PRICE_HC", 'Type' => "decimal(6,4)");
    $conf_index_col["START_TIME_HC"]        = array ( 'Field' => "START_TIME_HC", 'Type' => "varchar(5)");
    $conf_index_col["STOP_TIME_HC"]         = array ( 'Field' => "STOP_TIME_HC", 'Type' => "varchar(5)");
    $conf_index_col["COST_TYPE"]            = array ( 'Field' => "COST_TYPE", 'Type' => "varchar(20)");
    $conf_index_col["STATISTICS"]           = array ( 'Field' => "STATISTICS", 'Type' => "varchar(5)");
    $conf_index_col["SECOND_REGUL"]         = array ( 'Field' => "SECOND_REGUL", 'Type' => "varchar(5)");
    $conf_index_col["ADVANCED_REGUL_OPTIONS"] = array ( 'Field' => "ADVANCED_REGUL_OPTIONS", 'Type' => "varchar(5)");
    $conf_index_col["SHOW_COST"]            = array ( 'Field' => "SHOW_COST", 'Type' => "varchar(5)");
    $conf_index_col["SHOW_HISTORIC"]        = array ( 'Field' => "SHOW_HISTORIC", 'Type' => "varchar(5)");
    $conf_index_col["RESET_MINMAX"]         = array ( 'Field' => "RESET_MINMAX", 'Type' => "varchar(5)");
    $conf_index_col["WIFI"]                 = array ( 'Field' => "WIFI", 'Type' => "tinyint(1)");
    $conf_index_col["WIFI_SSID"]            = array ( 'Field' => "WIFI_SSID", 'Type' => "varchar(32)");
    $conf_index_col["WIFI_KEY_TYPE"]        = array ( 'Field' => "WIFI_KEY_TYPE", 'Type' => "varchar(10)");
    $conf_index_col["WIFI_PASSWORD"]        = array ( 'Field' => "WIFI_PASSWORD", 'Type' => "varchar(63)");
    $conf_index_col["WIFI_IP"]              = array ( 'Field' => "WIFI_IP", 'Type' => "varchar(15)");
    $conf_index_col["WIFI_IP_MANUAL"]       = array ( 'Field' => "WIFI_IP_MANUAL", 'Type' => "tinyint(1)");
    $conf_index_col["RTC_OFFSET"]           = array ( 'Field' => "RTC_OFFSET", 'Type' => "decimal(3,2)");
    $conf_index_col["ACTIV_DAILY_PROGRAM"]  = array ( 'Field' => "ACTIV_DAILY_PROGRAM", 'Type' => "varchar(5)", 'default_value' => "False");


    // Check if table configuration exists
    $sql = "SHOW TABLES FROM cultibox LIKE 'configuration';";
    
    $db = \db_priv_pdo_start("root");
    try {
        $sth=$db->prepare($sql);
        $sth->execute();
        $res = $sth->fetchAll(\PDO::FETCH_ASSOC);
    } catch(\PDOException $e) {
        $ret=$e->getMessage();
    }

    // If table exists, return
    if ($res == null)
    {
        
        // Buil MySQL command to create table
        $sql = "CREATE TABLE configuration "
                . "(id INT NOT NULL AUTO_INCREMENT PRIMARY KEY);";
        
        // Create table
        try {
            $sth = $db->prepare($sql);
            $sth->execute();
        } catch(\PDOException $e) {
            $ret = $e->getMessage();
            print_r($ret);
        }
        
    }
    
    $db = null;

    // Check column
    check_and_update_column_db ("configuration", $conf_index_col);
    
}


}

?>
