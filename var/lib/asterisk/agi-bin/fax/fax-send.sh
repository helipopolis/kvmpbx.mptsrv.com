#!/bin/bash

work_dir="/var/spool/asterisk/monitor/fax";
outgoing_dir="/var/spool/asterisk/outgoing";
context_to="long-distance";
send_to=$2;
email=$3;
file=$1;
id=`date +%s`;

echo $id fax to $send_to from $email file $file >> /var/log/asterisk/fax.log;

/usr/bin/gs -q -dNOPAUSE -dBATCH -sDEVICE=tiffg4 -sOutputFile=/var/spool/asterisk/monitor/fax/queue/$id.tif $file;

tif=`echo $time.tif`;

echo Channel: Local/$send_to\@$context_to > $work_dir/tmp/$id;
echo Context: fax-tx-web >> $work_dir/tmp/$id;
echo Extension: send >> $work_dir/tmp/$id;
echo MaxRetries: 2 >> $work_dir/tmp/$id;
echo RetryTime: 600 >> $work_dir/tmp/$id;
echo WaitTime: 30 >> $work_dir/tmp/$id;
echo Set: PICTURE=$work_dir/queue/$id.tif >> $work_dir/tmp/$id;
echo Set: EMAIL=$email >> $work_dir/tmp/$id;

sleep 1s;
/bin/mv $work_dir/tmp/$id $outgoing_dir;

