#!/bin/bash
#Add new users from arg!
#This script for add user 
#Please, dont delete
while [ -n "$1" ]
do
usr=$1
useradd $usr -m -s /bin/bash
printf "$usr:1" | chpasswd &> /dev/null
pdpl-user -l0:0 -i 63 $usr &> /dev/null
shift
done
