#!/bin/bash

# Получаем количество всех контактов в системе
total=`sudo asterisk -rx "pjsip show contacts" | grep "Contact" | wc -l`
# Получаем число активных контактов
active=`sudo asterisk -rx 'pjsip show contacts' | grep Avail | wc -l`
# Получаем имена контактов с проблемам
offline=`sudo asterisk -rx 'pjsip show contacts' | grep Unavail | wc -l`
# Сравниваем общее число с числом активных контактов и выводим сообщение об их состоянии
if [ $offline != 0 ]
then
echo Contacts offline $offline
else
echo All contacts are online
fi
