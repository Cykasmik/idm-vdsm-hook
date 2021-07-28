IdM
create a user (ie. vdsm)

create a role (ie. vdi-admin)

  add privilieges  
  
  - Host Administrators
  - DNS Administrators
  - Host Enrollment

add vdsm user to role


Hypervisor

ipa-getkeytab -s idm.example.lab-p vdsm@EXAMPLE.LAB -k /var/lib/vdsm/vdsm.keytab


chown vdsm. /var/lib/vdsm/vdsm.keytab

chmod 600 /var/lib/vdsm/vdsm.keytab


copy this keytab to all hypervisors


Hook Scripts

/usr/libexec/vdsm/hooks/before_vm_start/99_before_vm_start.sh

/usr/libexec/vdsm/hooks/after_vm_destroy/99_after_vm_destroy.sh


chown root.root 
chmod 755



Guest Template

/etc/systemd/system/vdi-config.service

/usr/local/sbin/vdi-config.sh


systemctl enable vdi-config

chmod 755 /usr/local/sbin/vdi-config.sh








