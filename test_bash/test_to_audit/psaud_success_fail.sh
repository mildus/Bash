#!/bin/bash
#
#Author: Ильдус Маняков
#Review: Роман Кузнецов
#
#VARIABLES
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
COFF=$(tput sgr0)

SCRIPT_DIR=""
ADMIN=""

#OK-FAIL
function check() {
    if [[ $? == 0 ]]; then
        printf "$1: ${GREEN}OK${COFF}\n"
    else
        printf "$1: ${RED}FAIL${COFF}\n"
        # exit 1
    fi
}

#SETPRIV
sudo apt-get install -y setpriv &> /dev/null
I=`dpkg -s setpriv  | grep "Status" `  &> /dev/null
if [ -n "$I" ] 
then
   check "setpriv installed"  #&> /dev/null
else
   check "setpriv not installed! Please check the network"  #&> /dev/null
   exit 0
fi

#CLEAN LOG-FILE
> /var/log/parsec/kernel.mlog

#START SUCCESS 
sudo chmod 777 ${SCRIPT_DIR}/psaud_success.sh &> /dev/null
sudo /${SCRIPT_DIR}/psaud_success.sh ${ADMIN}                                        

#START FAIL
sudo cp psaud_fail.sh /home/${ADMIN} &> /dev/null
sudo chmod 777 /home/${ADMIN}/psaud_fail.sh &> /dev/null
runuser -l ${ADMIN} -c "/home/${ADMIN}/psaud_fail.sh ${ADMIN}"