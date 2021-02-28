#!/bin/bash
#This is a script for testing сeph

#This block is for testing the connection
function check_ping {
 HST="sudcm suac sufs susrv"
 sleep $1
 function isOnline ()
 {
    result=1
  curtime=$(($(date +%s)))
  stoptime=$(($curtime + 60))
  while [ "$result" -ne "0" ] && [ "$curtime" -lt "$stoptime" ]
   do
    ping -q -c 1 $H > /dev/null 2>&1
    result=$?
    curtime=$(($(date +%s)))
#  echo "ping $H"
   done
 # echo $result
  return $result
 }
 for H in $HST
  do
    isOnline $H
  done
}
 rebt (){
 for nodes in sudcm susrv sufs
  do
    su ceph-adm -l -c "ssh -t ceph-adm@${nodes} 'sudo shutdown -r now'"
  done
}
check_ping 7
echo -e "\e[1;33;4;44mAdd user\e[0m"
./user_add.exp > /dev/null
check_ping 7
echo -e "\e[1;33;4;44mGenerate ssh-key\e[0m"
./ssher.exp suac sudcm susrv sufs > /dev/null
check_ping 7
cp ceph_deploy.sh /home/ceph-adm/
chown ceph-adm: /home/ceph-adm/ceph_deploy.sh
chmod +x /home/ceph-adm/ceph_deploy.sh
