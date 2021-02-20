#!/bin/bash
# Задаем периодичность опроса шлюзов.
# 30s - 30 секунд
# 10m - 10 минут
# 1h - 1 час
check_period="1m"
rtkoffline=0

while [ 1 ] 
do
  offline=`asterisk -rx "pjsip show contacts"|grep Unavail|grep rtk -c`

  if [ $offline != $rtkoffline ]
    then
      if [ $offline = 1 ]
        then
          curl https://api.telegram.org/bot320710048:AAHIMEi3p6VLSUCDp-93iQOI3LD1TBsVaWo/sendmessage -d chat_id=-1001350395958 -d text="sip РТК НЕДОСТУПЕН"
        else
          curl https://api.telegram.org/bot320710048:AAHIMEi3p6VLSUCDp-93iQOI3LD1TBsVaWo/sendmessage -d chat_id=-1001350395958 -d text="sip РТК доступен"
      fi
      rtkoffline=$offline
  fi
  sleep ${check_period}
done
