<?php
error_reporting(-1);
if($_FILES["file"]["size"] > 1024*10*1024)
{
echo ("Размер файла превышает 10 мегабайт");
exit;
}
exec('/var/lib/asterisk/agi-bin/fax/fax-send.sh '.$_FILES["file"]["tmp_name"].' '.$_POST["number"].' '.$_POST["email"], $a);
echo('<center>Факс поставлен в очередь на отправку</center>');
?>
