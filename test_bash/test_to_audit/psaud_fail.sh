#!/bin/bash
#
#Author: Ильдус Маняков
#Review: Роман Кузнецов
#
#VARIABLES
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
COFF=$(tput sgr0)

admin=$1

#FUNCTIONS
#Print result message
function check() {
    if [[ $? == 0 ]]; then
        printf "$1: ${GREEN}OK${COFF}\n"
    else
        printf "$1: ${RED}FAIL${COFF}\n"
        # exit 1
    fi
}

#Grep kernlog
function psgrepf() {
	sudo parselog /var/log/parsec/kernel.mlog | grep $! | grep "[f]" | grep $1  &> /dev/null 
}

#Grep kernlog
function greppid() {
	sudo parselog /var/log/parsec/kernel.mlog | grep $PID | grep "[f]" | grep $1 &> /dev/null
}

#MAIN
echo -e "\e[1;33;4;44mFailure test:\e[0m"

#open_fail
(sleep 0.1; cat qqq 2> /dev/null &> /dev/null) &
sudo psaud $! 0:o &> /dev/null
sleep 0.2;
psgrepf 'open(\"/home/'${admin}'/qqq' &> /dev/null
check '| open fail'

#create_fail
(sleep 0.2; touch /file 2> /dev/null &> /dev/null) &
sudo psaud $! 0:c  &> /dev/null
sleep 0.3; 
psgrepf 'create(\"/file' &> /dev/null
check '| create file fail'

#exec_file
sudo chmod o-x /bin/ls &> /dev/null
(sleep 0.2; /bin/ls >/dev/null &> /dev/null) &
sudo psaud $! 0:x  &> /dev/null
sleep 0.3;
psgrepf 'exec(\"/bin/ls' &> /dev/null
check '| execute fail'
sudo chmod o+x /bin/ls  &> /dev/null

#rm_file
sudo touch /tmp/file &> /dev/null
(sleep 0.2; rm /tmp/file >/dev/null &> /dev/null) &
sudo psaud $! 0:u &> /dev/null
sleep 0.3;
psgrepf 'unlink(\"/tmp/file' &> /dev/null
check '| delete fail'
sudo rm /tmp/file  &> /dev/null

#chmod_fail
sudo touch /tmp/file &> /dev/null
(sleep 0.1; chmod 700 /tmp/file &> /dev/null &> /dev/null) &
sudo psaud $! 0:d &> /dev/null
sleep 0.3;
psgrepf 'chmod("/tmp/file' &> /dev/null
check '| chmod fail'                    
sudo rm /tmp/file  &> /dev/null

#chown_fail
sudo touch /tmp/file;  &> /dev/null
(sleep 0.2; chown :users /tmp/file &> /dev/null &> /dev/null) &
sudo psaud $! 0:n &> /dev/null
sleep 0.3;
psgrepf 'chown("/tmp/file' &> /dev/null
check '| chown  fail'
sudo rm /tmp/file  &> /dev/null

#mount_fail
rm dir >/dev/null  &> /dev/null 
(sleep 0.2; sudo mount --bind dir /mnt/ > /dev/null &> /dev/null & echo $ >/tmp/pid1) &
sudo psaud $! 0:t &> /dev/null
sleep 0.3;
PID=`cat /tmp/pid1`
greppid 'mount("/home/'${admin}'/dir' &> /dev/null                                          
check '| mount fail'
sudo rm /tmp/pid* &> /dev/null

#module_fail
touch /home/${admin}/hello.ko &> /dev/null
echo 'MODULE_LICENSE("Dual BSD/GPL\");' > /home/${admin}/hello.ko
(sleep 0.1;sudo insmod /home/${admin}/hello.ko > /dev/null &> /dev/null & echo $! > /tmp/pid3) &
sudo psaud $! 0:l &> /dev/null 
sleep 0.3;
PID=`cat /tmp/pid3`
greppid  'init_module("\[invalid' &> /dev/null
check '| module fail'           
sudo rm /home/${admin}/hello.ko /tmp/pid3 &> /dev/null

#uid_fail
(sleep 0.2; setpriv --reuid 0 bash 2 > /dev/null &> /dev/null) &
sudo psaud $! 0:i &> /dev/null
sleep 0.3;
psgrepf "setresuid(0,0,0)"  &> /dev/null
check '| uid  fail'

#gid_fail
(sleep 0.1;setpriv --regid 0 --groups  0 bash 2 > /dev/null &> /dev/null) &
sudo psaud $! 0:g   &> /dev/null
sleep 0.3;
psgrepf "setresgid(0,0,0)"  &> /dev/null
check '| gid  fail'

#acl_fail
sudo mkdir dir &> /dev/null
(sleep 0.1; setfacl -m u:${admin}:rx  dir > /dev/null &> /dev/null ) &
sudo psaud $! 0:r &> /dev/null
sleep 0.3;
psgrepf 'setacl(\"/home/'${admin}'/dir' &> /dev/null
check '| acl fail'
sudo rm -r dir &> /dev/null

#mac_fail
mkdir dir &> /dev/null
(sleep 0.1; sudo pdpl-file 5:63:0:ccnri dir > /dev/null &> /dev/null & echo $! > /tmp/pid2) &
sudo psaud $! 0:m &> /dev/null
sleep 0.3;
PID=`cat /tmp/pid2`
greppid 'parsec_chmac(\"/home/'${admin}'/dir\",5:63:0x0:0x2!:)' &> /dev/null
check '| mac fail'
rm -r dir /tmp/pid2 &> /dev/null

#cap_fail
(sleep 0.1; pscaps $(echo $$) 0x1 > /dev/null &> /dev/null) &
sudo psaud $! 0:p &> /dev/null
sleep 0.3;
psgrepf 'parsec_capset(' &> /dev/null
check '| cap fail'

#chroot_fail
(sleep 0.1; /usr/sbin/chroot /tmp/ > /dev/null &> /dev/null) &
sudo psaud $! 0:h &> /dev/null
sleep 0.3;
psgrepf 'chroot("/tmp/")' &> /dev/null
check '| chroot fail'

#rename_fail
sudo touch /tmp/file1 &> /dev/null
(sleep 0.1; mv /tmp/file1 /tmp/file2 > /dev/null &> /dev/null) &
sudo psaud $! 0:e &> /dev/null    
sleep 0.3;
psgrepf 'rename("/tmp/file1' &> /dev/null
check '| rename  fail'
sudo rm /tmp/file1 &> /dev/null

#net_fail
#cat /bin/ping > /tmp/xping
#chmod +x /tmp/xping
(sleep 0.3; ping6 -c 1 localhost &> /dev/null) &
sudo psaud $! 0:w &> /dev/null
sleep 0.3;
psgrepf 'connect' &> /dev/null
check '| net fail'
#rm /tmp/xping