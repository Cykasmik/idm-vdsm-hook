#!/bin/bash
#

clear
echo -e "\n\nPlease wait while Virtual Machine is registred to IdM\n\n" 1>&2

DEVICE=$(nmcli device show | grep DEVICE | grep -v lo | awk '{print $2}')

typeset -u MAC
MAC=$(nmcli device show ${DEVICE} | grep HW | awk '{print $2}')

OCTET1=$((0x$(echo ${MAC} | awk -F\: '{print $3}')))
OCTET2=$((0x$(echo ${MAC} | awk -F\: '{print $4}')))
OCTET3=$((0x$(echo ${MAC} | awk -F\: '{print $5}')))
OCTET4=$((0x$(echo ${MAC} | awk -F\: '{print $6}')))

IP="${OCTET1}.${OCTET2}.${OCTET3}.${OCTET4}"
GW="${OCTET1}.${OCTET2}.${OCTET3}.1"
DNS="172.16.1.12"

nmcli con del ${DEVICE}
nmcli con add con-name ${DEVICE} ifname ${DEVICE} type ethernet ip4 ${IP}/24 gw4 ${GW}
nmcli con mod ${DEVICE} ipv4.dns "${DNS}"
nmcli con up ${DEVICE}

HOST=$(host ${IP} | awk '{print $5}' | sed 's/\.$//')

hostnamectl set-hostname ${HOST}
ipa-client-install --hostname=$(hostname -f) --password=${MAC} --automount-location=$(hostname -d) --no-ntp --unattended 2>&1 > /dev/null

# ensure SELinux allows nfs home directories
setsebool -P use_nfs_home_dirs=1 

systemctl restart autofs
systemctl disable vdi-config

echo -e "\n\nYou may now login\n" 1>&2
exit 0

