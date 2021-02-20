#!/bin/bash

# Получаем количество всех транков в системе
total=`sudo asterisk -rx "pjsip show registrations" | grep "Objects" | awk '{print $3}'`
# Получаем число активных транков
active=`sudo asterisk -rx 'pjsip show registrations' | sed -n '/Registered/p' | wc -l`
# Получаем имена транков с проблемам
offline=`sudo asterisk -rx 'pjsip show registrations' | sed -n '/Request\|Rejected\|Authentication\|Unregistered/p' | wc -l`
# Сравниваем общее число с числом активных транков и выводим сообщение об их состоянии
if [ $active != $total ]
then
echo Trunks offline $offline
else
echo All trunks are online
fi
