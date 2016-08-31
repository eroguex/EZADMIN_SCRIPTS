#!/bin/bash

`cp -a /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0:0`

echo "Please enter new IP"
read -p ":" IPADDR
read -r -p "Are you sure it's - $IPADDR [y/N]" response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
    sed -i "s/109.228.49.50/${IPADDR}/g" /etc/sysconfig/network-scripts/ifcfg-eth0:0
else
    echo "Please enter the correct IP"
    exit
fi
