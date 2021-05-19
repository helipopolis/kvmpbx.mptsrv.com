#!/usr/bin/php -q
<?php
require('phpagi.php'); //подключаем библиотеку phpagi.php
$agi = new AGI();
$stdin = fopen('php://stdin', 'r');
$stdout = fopen('php://stdout', 'w');
/*
Вынесем отправку в телеграм в отдельную функцию send, последний параметр укажем как необязательный т.к. для тестовых сообщений используются бесплатные прокси – без пароля
*/
function send($token, $chatid, $text, $proxy, $auth=NULL){
$ch=curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://api.telegram.org/bot'.$token.'/sendMessage');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, false);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, 'chat_id='.$chatid.'&text='.urlencode($text));
curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);
//curl_setopt($ch, CURLOPT_HTTPPROXYTUNNEL, 1);
//curl_setopt($ch, CURLOPT_PROXY, $proxy);
//curl_setopt($ch, CURLOPT_PROXYTYPE, CURLPROXY_SOCKS5);
//if($auth){
//curl_setopt($ch, CURLOPT_PROXYUSERPWD, $auth);
//}
var_dump($ch);
// Отправляем сообщение
$curl_exec=curl_exec($ch);
/*
//Для отладки в скрипте можно добавить dump какой-либо переменной, например $result. Результат вывода var_dump($result) отобразится в консоли Астериска при включенном режиме отладки agi - agi set debug on
*/
var_dump($result);
curl_close($ch);
return $result;
}
// Токен бота и идентификатор чата
$token='1032660733:AAFM_g0a4Zftu9tIS1sPvFHJzT60djtmE-Y';
//id чата оператора в telegram
$chatid = 144486820;
/* Текст сообщения. Переданные в скрипт аргументы (номер звонящего и дата звонка) - $argv[1] и $argv[2] */
$text='Звонил ' . $argv[1] . ' Дата ' . $argv[2];
// Настройки прокси
$proxy='185.58.194.54:442';
$auth='proxyuser:phu1eeYa'; //пароль, если прокси – с паролем, в формате 'login:password'
// Отправка сообщения в личный Telergam чат
send($token, $chatid, $text, $proxy);
fclose ($stdin);
fclose ($stdout);
exit(0);
?>
