#!/bin/bash

# Получаем количество всех транков в системе
total=`sudo asterisk -rx "iax2 show peers" | grep "iax2 peers"| awk '{print $1}'`
# Получаем число активных транков
active=`sudo asterisk -rx "iax2 show peers" | sed -n '/OK\|Unmonitored/p' | wc -l`
# Получаем имена транков с проблемам
offline=`sudo asterisk -rx "iax2 show peers" | sed -n '/UNREACHABLE/p' | wc -l`
# Сравниваем общее число с числом активных транков и выводим сообщение об их состоянии
if [ $active -lt $total ]
then
        echo IAX Trunks offline $offline
else
        echo All IAX trunks are online
fi
