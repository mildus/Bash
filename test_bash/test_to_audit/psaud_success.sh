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
admin_uid=$(id -u $admin)
admin_gid=$(id -g $admin)


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
function psgrep() {
	parselog /var/log/parsec/kernel.mlog | grep $! | grep "[s]" | grep $1 &> /dev/null
}

#MAIN
echo -e "\e[1;33;4;44mSuccess test:\e[0m"

#open_success
(sleep 0.1; cat /etc/passwd &> /dev/null) &  
psaud $! o:0 &> /dev/null                                    
sleep 0.2;                                  
psgrep  "/etc/passwd" &> /dev/null
check '| open success'                      

#create_success
(sleep 0.1; touch /tmp/file &> /dev/null) &  
psaud $! c:0 &> /dev/null
sleep 0.2;
psgrep "/tmp/file" &> /dev/null                                
check '| create success'

#exec_success
(sleep 0.1; /bin/true &> /dev/null) &
psaud $! x:0 &> /dev/null
sleep 0.3;
psgrep 'exec(\"/bin/true' &> /dev/null
check '| execute success'

#rm_file_success
(sleep 0.1; rm /tmp/file &> /dev/null) &
PID=$!                                      
psaud $PID u:0 &> /dev/null
sleep 0.3;
psgrep 'unlink(\"/tmp/file' &> /dev/null
check '| delete success '

#chmod_success
touch /tmp/file &> /dev/null
(sleep 0.1; chmod 700 /tmp/file &> /dev/null) &          
psaud $! d:0 &> /dev/null
sleep 0.3;                  
psgrep 'chmod(\"/tmp/file' &> /dev/null
check '| chmod success'                     

#chown_success
(sleep 0.1; chown :users /tmp/file &> /dev/null) &
psaud $! n:0 &> /dev/null
sleep 0.3;
psgrep 'chown(\"/tmp/file' &> /dev/null
check '| chown  success'

#mount_success
mkdir -p /dir &> /dev/null
(sleep 0.1; mount --bind /dir /mnt/ &> /dev/null) &
psaud $! t:0 &> /dev/null
sleep 0.3;
psgrep 'mount("/dir' &> /dev/null
check '| mount  success'
umount /mnt &> /dev/null
rm -r /dir

#module_success
(sleep 0.1; modprobe 8021q &> /dev/null) &
psaud $! l:0 &> /dev/null
sleep 0.3;
psgrep 'init_module(\"8021q' &> /dev/null
check '| module  success'
modprobe -r 8021q &> /dev/null

#uid_success
(sleep 0.1; sudo -u ${admin} /bin/true &> /dev/null) &
psaud $! i:0 &> /dev/null
sleep 0.3;
psgrep "setresuid(-1,$admin_uid" &> /dev/null
check '| uid  success'

#gid_success
(sleep 0.1; sudo -u ${admin} /bin/true &> /dev/null) &
psaud $! g:0 &> /dev/null
sleep 0.3;
psgrep "setresgid(-1,$admin_gid" &> /dev/null
check '| gid  success'

#acl_success
mkdir /tmp/dir &> /dev/null
(sleep 0.2; setfacl -m u:${admin}:rx /tmp/dir &> /dev/null) &
psaud $! r:0 &> /dev/null    
sleep 0.3;
psgrep 'setacl(\"/tmp/dir' &> /dev/null
check '| acl success'
rm -r /tmp/dir &> /dev/null    

#mac_success
mkdir /dir &> /dev/null
(sleep 0.1; pdpl-file 0:63:0:ccnri /dir &> /dev/null) &
psaud $! m:0 &> /dev/null
sleep 0.3;
psgrep 'parsec_chmac("/dir",0:63:0x0:0x2!:' &> /dev/null
check '| mac  success'
rm -r /dir &> /dev/null

#cap_success
useradd test &> /dev/null
(sleep 0.1; usercaps -l 0x1 test &> /dev/null & echo $! > /tmp/pid) &
psaud $! p:0 &> /dev/null
sleep 0.3;
PID=`cat /tmp/pid`
parselog /var/log/parsec/kernel.mlog | grep $PID | grep "[s]" | grep "modify(" &> /dev/null
check '| cap success'
usercaps -z test >/dev/null &> /dev/null
userdel test &> /dev/null

#chroot_success
(sleep 0.1; chroot / &> /dev/null) &
psaud $! h:0 &> /dev/null
sleep 0.3;
psgrep 'chroot(\"/' &> /dev/null
check '| chroot  success'

#rename_success
touch /tmp/file1 &> /dev/null
(sleep 0.1; mv /tmp/file1 /tmp/file2  &> /dev/null) &
psaud $! e:0 &> /dev/null
sleep 0.3;
psgrep 'rename("/tmp/file1' &> /dev/null
check '| rename  success'
rm /tmp/file2 &> /dev/null

#net_success
(sleep 0.1; ping -c 1 localhost &> /dev/null) &
psaud $! w:0 &> /dev/null
sleep 0.3;
psgrep 'connect(SOCK_D' &> /dev/null
check '| net  success'
