#!/bin/bash
#author imanyakov
#This script for test ceph-cluster

#This block is for testing the connection
if [[ "$USER" != "ceph-adm" ]]
  then echo "This script must be run as ceph-adm" && exit 1
fi
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
    echo "Проверка доступности $H"
    done
  return $result
  }
  for H in $HST
    do
      isOnline $H
    done
}
#This block for removing configs
#ceph-deploy purge ceph-node1 ceph-node2 ceph-node3 ceph-node4 >/dev/null 2>&1 &
#ceph-deploy purgedata ceph-node1 ceph-node2 ceph-node3 ceph-node4  >/dev/null 2>&1 &
#ceph-deploy forgetkeys  >/dev/null 2>&1 &
#sudo rm ceph.*
#sudo rm -r /etc/ceph/*
#check_ping 3
#sudo rm -r cluster
sudo apt install ceph-deploy

#deploy
ceph-deploy install sudcm susrv sufs
check_ping 3
#creat_mon
ceph-deploy new sudcm
ceph-deploy mon create-initial
#key_send
ceph-deploy admin suac sudcm susrv sufs
#creat_mgr
ceph-deploy mgr create sudcm
#clear_disk
check_ping 3
ceph-deploy disk zap sudcm /dev/sd{b,c}
check_ping 3
ceph-deploy disk zap susrv /dev/sd{b,c}
check_ping 3
ceph-deploy disk zap sufs /dev/sd{b,c}
#creat osd
check_ping 3
ceph-deploy osd create --data /dev/sdb sudcm
ceph-deploy osd create --data /dev/sdc sudcm
check_ping 3
ceph-deploy osd create --data /dev/sdb susrv
ceph-deploy osd create --data /dev/sdc susrv
check_ping 3
ceph-deploy osd create --data /dev/sdb sufs
ceph-deploy osd create --data /dev/sdc sufs
ssh sudcm sudo ceph health
#install_client
ceph-deploy install --cli suac
ceph-deploy admin suac
sudo ceph osd pool create rbd 128
sudo rbd pool init rbd
sudo rbd create testrbd --size 4096 --image-feature layering
sudo rbd map testrbd --name client.admin
#create_mds
ceph-deploy --username ceph-adm install --mds suac
ceph-deploy --username ceph-adm mds create suac
#dev_form & mount
sudo mkfs.ext4 -m0 /dev/rbd/rbd/testrbd
sudo mkdir /mnt/ceph-device
sudo mount /dev/rbd/rbd/testrbd /mnt/ceph-device