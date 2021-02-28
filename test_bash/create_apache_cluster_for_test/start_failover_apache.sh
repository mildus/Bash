#/bin/bash
#author imanyakov
#this script execute ap_server.sh lacal and remote

#admin other host
OTHER_USER=""
SCRIPTS_DIR=""

#check root
root_uid=0
e_notroot=67
    if [ "$UID" -ne "$root_uid" ]
        then
        echo "Для работы сценария запустить от root"
        exit $e_not_root
    fi

#OTHER_IP =
    if [ $HOSTNAME == "suac" ]
        then
        OTHER_NAME=susrv
        else
        OTHER_NAME=suac
    fi

#check hostname, hostname can be suac or susrv
e_nothost=66
    if [ $HOSTNAME != "suac" ] && [ $HOSTNAME != "susrv" ]
        then
        echo "Запустить на suac или susrv"
        exit $e_nothost
    fi

cd $SCRIPTS_DIR
#install sshpass for remote execute
dpkg -s sshpass 2>/dev/null >/dev/null || sudo apt-get -y install sshpass >/dev/null

#copy ap_server.sh for other host
sshpass -p "1" scp -o StrictHostKeyChecking=no -r ap_server.sh $OTHER_USER@$OTHER_NAME:/home/u

#delite next line
sshpass -p "1" scp -o StrictHostKeyChecking=no -r pcs_0.9.155+dfsg-2+deb9u1.astra1_all.deb $OTHER_USER@$OTHER_NAME:/home/u

#running script local-remote
/bin/bash ap_server.sh install_set
sshpass -p "1" ssh $OTHER_USER@$OTHER_NAME "sudo ./ap_server.sh install_set; exit"
sleep 3
./ap_server.sh setup_cluster
sleep 3
./ap_server.sh cluster_start1
sleep 3
sshpass -p "1" ssh $OTHER_USER@$OTHER_NAME "sudo ./ap_server.sh cluster_start1; exit"
./ap_server.sh cluster_start2
sleep 3
sshpass -p "1" ssh $OTHER_USER@$OTHER_NAME "sudo ./ap_server.sh cluster_start2; exit"
./ap_server.sh set_html
sshpass -p "1" ssh $OTHER_USER@$OTHER_NAME "sudo ./ap_server.sh set_html; exit"
echo "Настройка завершена!"