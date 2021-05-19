#!/usr/bin/php -q
<?php
require('phpagi.php'); 
$agi = new AGI(); 
$cid = $agi->request['agi_callerid'];
$key = '255d6e88-133c-4e38-8f0a-32a10337329c';
$yandex_url = "https://search-maps.yandex.ru/v1/?text=$cid&results=1&type=biz&lang=ru_RU&apikey=$key";
$ch = curl_init();
curl_setopt ($ch, CURLOPT_URL,$yandex_url);
curl_setopt ($ch, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6");
curl_setopt ($ch, CURLOPT_TIMEOUT, 60);
curl_setopt ($ch, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
$yandex = curl_exec ($ch);
curl_close($ch);
$yandex_o = json_decode($yandex, true);
$views = $yandex_o['features'][0]['properties']['CompanyMetaData']['name'];
if (empty($views)) {$agi->set_variable("lookupcid", "0");}  else {
$agi->set_variable("lookupcid", "$views");
} 
?>
