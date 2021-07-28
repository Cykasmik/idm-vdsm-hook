#!/bin/bash
#
########################################################################
# RHV hook to automate creation of workstations in kerberos realm
#
# David Pinkerton (pinky@redhat.com)
# Feb 2019
#
# Disclaimer:
# This script is NOT SUPPORTED by Red Hat Global Support Services.
#
# The following information has been provided by Red Hat, but is outside the scope of the 
# posted Service Level Agreements and support procedures.
#
# It is supplied in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Installing unsupported packages does not necessarily make a system unsupportable by Red Hat 
# Global Support Services. However, Red Hat Global Support Services will be unable to support 
# or debug problems with packages not shipped in standard RHEL channels.
#
########################################################################

# variables
VDI_USER="vdsm@EXAMPLE.LAB"
VDI_KRB5="/var/lib/vdsm/vdsm.keytab"

HOST_PREFIX="workstation"
HOST_DOMAIN=$(hostname -d)

# extract VM MAC address from RHV json info (upper case)
typeset -u MAC
MAC=$(vdsm-client VM getInfo vmID=${vmId} | grep macAddr | awk -F\" '{print $4}')

# exit quietly if not VDI VM (ie. Self Hosted Engine)
[[ $(echo ${MAC} | grep "^00:02") ]] || exit 0

# fail if keytab file not found (a non-zero exit code will cause RHV Launch to fail!)
[[ -f ${VDI_KRB5} ]] || exit 1

# obtain kerberos tgt
kinit -kt ${VDI_KRB5} ${VDI_USER}

# extract IP octets from MAC
OCTET1=$((0x$(echo ${MAC} | awk -F\: '{print $3}')))
OCTET2=$((0x$(echo ${MAC} | awk -F\: '{print $4}')))
OCTET3=$((0x$(echo ${MAC} | awk -F\: '{print $5}')))
OCTET4=$((0x$(echo ${MAC} | awk -F\: '{print $6}')))

# right pad 4 places with zeros
HOST_SUFFIX=$(printf "%04d" ${OCTET4})

# create VM kerberos principal
ipa host-add "${HOST_PREFIX}${HOST_SUFFIX}.${HOST_DOMAIN}" --ip-address="${OCTET1}.${OCTET2}.${OCTET3}.${OCTET4}" --macaddress=${MAC} --desc="$(date +%s)" --password="${MAC}"

# destroy kerberos ticket (quietly)
kdestroy -qA

exit 0

