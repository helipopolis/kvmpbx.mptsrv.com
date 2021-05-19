#!/usr/bin/php -q
<?php
$agivars = array();
while (!feof(STDIN)) {
    $agivar = trim(fgets(STDIN));
    if ($agivar === '')
        break;
    $agivar = explode(':', $agivar);
    $agivars[$agivar[0]] = trim($agivar[1]);
}
extract($agivars);
 
$text = $_SERVER["argv"][1];
$md5 = md5($text);
$prefix = '/var/lib/asterisk/saycache/';
$key = '';
#$speaker = 'jane';
$speaker = 'oksana';
#$speaker = 'alyss';
#$speaker = 'omazh';
#$speaker = 'zahar';
#$speaker = 'ermil';
$emotion = 'good';
#$emotion = 'evil';
$quality = 'lo';
$speed = '1.0';
$lang = 'ru-RU';
$format = 'wav';
$filename = $prefix.$md5;
 
if (!file_exists($filename.'.wav')) {
    exec('curl "https://tts.voicetech.yandex.net/generate?format='.$format.'&quality='.$quality.'&speed='.$speed.'&lang='.$lang.'&speaker='.$speaker.'&emotion='.$emotion.'&key='.$key.'" -G --data-urlencode "text='.$text.'" > '.$filename.'.wav');
}
 
echo 'EXEC Background "'.$filename.'" ""'."\n";
exit(0);
?>
