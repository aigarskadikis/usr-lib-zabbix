#!/usr/bin/php
<?php

if(!isset($argv[1]) && !isset($argv[2])) exit("ZBX_NOTSUPPORTED");
$argv[1] = (explode("|", $argv[1] ));

$jsonresult = array("data"=>array());

foreach ($argv[1] as $value) {

    switch ($argv[2]) {

        case "tablespaces":

            $jsonresult['data'][]=array('{#TBSNAME}'=>$value,'{#DSN}'=>$value);

    }                             
          
}      
  
echo json_encode($jsonresult);

?>
