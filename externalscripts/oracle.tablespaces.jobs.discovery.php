#!/usr/bin/php
<?php

if(!isset($argv[1]) && !isset($argv[2])) exit("ZBX_NOTSUPPORTED");
$argv[1] = (explode("|", $argv[1] ));

# create a new json array: '{data:[]}'
$jsonresult = array("data"=>array());

foreach ($argv[1] as $value) {
	
$connected_dsn = odbc_connect($value,"","");

if(!$connected_dsn) exit('SQL connection erorr | ZBX_NOTSUPPORTED');

    switch ($argv[2]) {

        case "tablespaces":
        
            $sqlresult=odbc_exec($connected_dsn,"SELECT tablespace_name FROM dba_tablespaces;");

            while(odbc_fetch_row($sqlresult)){
				# put values inside '{data:[]}'
                $jsonresult['data'][]=array('{#TBSNAME}'=>odbc_result($sqlresult,1),'{#DSN}'=>$value);
            }
        break;
            
        case "jobs":
        
            $sqlresult=odbc_exec($connected_dsn,"SELECT job_name, owner FROM dba_scheduler_jobs WHERE state != 'DISABLED';");

            while(odbc_fetch_row($sqlresult)){
                $jsonresult['data'][]=array('{#JOBNAME}'=>odbc_result($sqlresult,1),'{#JOBOWNER}'=>odbc_result($sqlresult,2),'{#DSN}'=>$value);
            }

    }

}

echo json_encode($jsonresult);

?>
