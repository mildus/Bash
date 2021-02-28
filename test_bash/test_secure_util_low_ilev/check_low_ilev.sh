#!/bin/bash
#author imanyakov
#Checking astra tools with low integrity  administrator
#Pre make command astra-mic-control enable && set-fs-ilev

#Variable to check, you can edit
lst="astra-bash-lock
astra-commands-lock
astra-console-lock
astra-digsig-control
astra-hardened-control
astra-interpreters-lock
astra-lkrg-control
astra-macros-lock
astra-modban-lock
astra-mount-lock
astra-noautonet-control
astra-nobootmenu-control
astra-nochmodx-lock
astra-overlay
astra-ptrace-lock
astra-secdel-control
astra-shutdown-lock
astra-sudo-control
astra-sumac-lock
astra-swapwiper-control
astra-sysrq-lock
astra-ufw-control
astra-ulimits-control
astra-mic-control
"

#Check astra-mic-control
set-fs-ilev status
stat=$?
if
  [ $stat == 1 ]; then echo "Защита файловой системы не включена! Зайдите высокоцелостным админом и включите защиту файловой системы" && exit 1
elif
  [ $stat == 2 ]; then echo "Защита файловой системы включена частично, продолжим"
elif
  [ $stat == 0 ]; then echo -e "\033[35mЗащита файловой системы включена!\033[0m"
fi
 
#Check pdp-id
if
  pdp-id|grep "Уровень целостности:0" ; then echo "Целостность пользователя нулевая"
  else echo -e "\033[31mНеобходимо залогинится под низким уровнем целостности!!\033[0m" && exit 1
fi

#Check tmp file
 
if [ -e /media/ch2 ]; then rm  /media/ch1 /media/ch2 && echo -e "\033[35m3-й запуск скрипта! Временные файлы удалены!!\033[0m" && exit 1
fi

if [ -e /media/ch1 ]; then 
  echo -e "\033[35mВторой запуск скрипта, создан временный файл ch2\033[0m"
#    astra-autologin-control enable u 2>/dev/null
#    astra-autologin-control enable u 2>/dev/null>>/media/ch2
  for items in $lst
    do
     $items status &>/dev/null
     st=$?
     if
     [ $st == 1 ]; then $items enable 2>/dev/null
      else 
       $items disable  2>/dev/null
     fi
     status=`$items status 2>/dev/null`
     echo "$items $status" >> /media/ch2
    done
  
  echo -e "\033[35mСравнение статусов инструментов astra-* после перезагрузки:\033[0m"
  if diff /media/ch1 /media/ch2; then echo -e "\033[32mТест прошел, инструменты администрирования не работают у низкоцелостного админа (не переключаются в состояние enable или disable). Запустите скрипт еще раз для удаления временных файлов.\033[0m"
    else
      echo -e "\033[31mТест провален! Один из инструментов astra-* переключился в состояние enable или disable!\033[0m"
  fi    
fi

if [ ! -f /media/ch1 ]; then
   echo -e "\033[35mПервый запуск скрипта, создан временный файл ch1\033[0m"
#     astra-autolgin-control status 2>/dev/null>>/media/ch1
     for items in $lst
      do
       status=`$items status 2>/dev/null`
       echo "$items $status" >> /media/ch1
      done
    echo -e "\033[35mПерезагрузите компьютер, после перезагрузки войдите низкоцелостным пользователем и запустите скрипт заново\033[0m"
fi