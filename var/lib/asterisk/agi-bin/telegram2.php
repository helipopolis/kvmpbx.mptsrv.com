#!/usr/bin/php -q
<?php
require('phpagi.php'); 
$agi = new AGI(); 
$cid = $agi->request['agi_callerid'];
$phoneFieldset = "Входящий звонок с номера: ";
$token = "1032660733:AAFM_g0a4Zftu9tIS1sPvFHJzT60djtmE-Y";
$chat_id = "144486820";
$arr = array(
$phoneFieldset => $cid,
);
foreach($arr as $key => $value) {
$txt .= "".$key." ".$value."%0A";
};
$result = fopen("https://api.telegram.org/bot{$token}/sendMessage?chat_id={$chat_id}&parse_mode=html&text={$txt}","r");
var_dump($result);
return $result;
?>
