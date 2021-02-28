#!/bin/bash
#author imanyakov

#This script configures the Apache server on two hosts
#It is enough to run the script on one host.
#Variables can be specified manually

#VARIABLES
INTERFACE=eth0
SHARED_IP=10.0.0.100
#MY_IP=$(ip addr show dev $INTERFACE | grep -P '\d+\.\d+\.\d+.\d+\/\d+' -o | cut -f1 -d"/")
THIS_USER=$(grep ":1000:" /etc/passwd | cut -f 1 -d ":")

#other host ip, you can comment out this block and assign it manually
#in this modification of the script this variable is not used
#OTHER_IP =
e_notresolv=65
    if [ $HOSTNAME == "suac" ]
        then
        ping -q -c 1 susrv > /dev/null 2>&1
        echo $?
            if [ $? = 0 ]
            then
            OTHER_IP=$(host susrv | awk '{print $NF}')
            else echo "Не резолвится хост susrv"
            exit 1
            fi
    else
        ping -q -c 1 suac > /dev/null 2>&1
         if [ $? = 0 ]
            then
            OTHER_IP=$(host suac | awk '{print $NF}')
            else echo "Не резолвится хост suac"
            exit 1
            fi
    fi

#var for /etc/apache2/ports.conf
DEFAULT_PORTS_CONF="NameVirtualHost *:80\nListen 80"
#var for /etc/apache2/sites-available/000-default.conf
DEFAULT_CONF="<VirtualHost *:80>\n\tServerAdmin webmaster@localhost\n\tServerName $HOSTNAME.rtfm.rbt\n\tDocumentRoot /var/www/html/\n\t<Directory /var/www/html/>\n\t\tOptions Indexes FollowSymLinks MultiViews\n\t\tAllowOverride None\n\t\tAuthType Basic\n\t\tAuthName \"PAM authentication\"\n\t\tAuthBasicProvider PAM\n\tAuthPAMService apache2\n\t\tRequire valid-user\n\t</Directory>\n\tErrorLog /var/log/apache2/error.log\n\tLogLevel warn\n\tCustomLog /var/log/apache2/access.log combined\n</VirtualHost>"

#function for install package
install(){
count=1
    while [ -n "$1" ]
    do
        #echo "Parameter #$count = $1"
        dpkg -s $1 2>/dev/null >/dev/null || sudo apt-get -y install $1
        count=$(( $count + 1 ))
    shift
    done
}

#installing packages apache, pacemaker and host settings
install_set(){
    install apache2 libapache2-mod-authnz-pam
    echo -e $DEFAULT_PORTS_CONF >/etc/apache2/ports.conf
    echo -e $DEFAULT_CONF >/etc/apache2/sites-available/000-default.conf
    a2enmod authnz_pam
    usermod -a -G shadow www-data
        if lsb_release -c | grep -i smolensk
        then
            setfacl -d -m u:www-data:r /etc/parsec/macdb
            setfacl -R -m u:www-data:r /etc/parsec/macdb
            setfacl -m u:www-data:rx /etc/parsec/macdb
            echo "AstraMode off" >> /etc/apache2/apache2.conf
        fi
    systemctl restart apache2

    ####В СЛЕДУЮЩУЮ СТРОКУ ПОСЛЕ РЕВИЗИИ ДОБАВИТЬ pcs (install pacemaker pcs) И УДАЛИТЬ ДАННЫЙ КОММЕНТАРИЙ
    install pacemaker 
    #add later install pcs and delite next line - ДАННУЮ СТРОКУ И СЛЕДУЮЩУЮ УДАЛИТЬ ПОСЛЕ РЕВИЗИИ
    dpkg -i pcs_0.9.155+dfsg-2+deb9u1.astra1_all.deb

    apt install -f -y
    pcs cluster destroy
    echo  "hacluster:1" | chpasswd
    pdpl-user -c 0:0  hacluster 2>/dev/null
}

#reload and start cluster
cluster_start1(){
    systemctl restart pacemaker
    systemctl enable pacemaker
    pcs cluster start
    #pcs status
    #pcs property set stonith-enabled=false
    #pcs resource create ClusterIP ocf:heartbeat:IPaddr2 ip=$SHARED_IP cidr_netmask=24 op monitor interval=30
    #a2ensite default
    #service apache2 reload
}
cluster_start2(){
    pcs property set stonith-enabled=false
    pcs resource create ClusterIP ocf:heartbeat:IPaddr2 ip=$SHARED_IP cidr_netmask=24 op monitor interval=30 2>/dev/null
    a2ensite default 2>/dev/null
    service apache2 reload
}
set_html(){
    html_simple="<!DOCTYPE HTML>\n<html>\n<head>\n\t<meta charset=\"utf-8\">\n\t<title>ТЕСТ отказоустойчивого сервера</title>\n</head>\n<body>\n\t<p>Страница загружена с $HOSTNAME</p>\n</body>\n</html>"
    echo -e $html_simple >/var/www/html/index.html
}
case $1 in
    install_set)
        install_set
    ;;
    setup_cluster)
        pcs cluster auth susrv.rtfm.rbt suac.rtfm.rbt -u hacluster -p 1 2>/dev/null
        pcs cluster setup --force --name CLUSTERNAME  susrv.rtfm.rbt suac.rtfm.rbt 2>/dev/null
    ;;
    cluster_start1)
        cluster_start1
    ;;
    cluster_start2)
        cluster_start2
    ;;
    set_html)
        set_html
    ;;
esac