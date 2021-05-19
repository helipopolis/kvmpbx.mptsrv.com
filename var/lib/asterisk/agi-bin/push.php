<?php
$serverKey = "AIzaSyCkOMsUwTnZfXXo1rqNPceMNxJcNSixRZU";
$notif = ['title' => 'You have a call', 'body' => "Call from $CLI"];
$headers = [CURLOPT_HTTPHEADER => ["Authorization: key=$serverKey", 'Content-Type: application/json']];
$pjsipContact = ast_get_var("PJSIP_AOR(1000,contact)");
if(!empty($pjsipContact)) {
  $pjsipUri = ast_get_var("PJSIP_CONTACT($pjsipContact,uri)");
  preg_match('/pn-tok=([^;]+)/', $pjsipUri, $toArr);
  if (count($toArr) == 2) {
    log_cli("send noti to {$toArr[1]}");
    curlGetPage('https://fcm.googleapis.com/fcm/send', json_encode(['to' => $toArr[1], 'notification' => $notif]), $headers, 443, 'POST', TRUE);
  }
}
?>
