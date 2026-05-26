Task 1: Network Configuration

Bash


nmcli connection modify enp1s0 ipv4.addresses 192.168.122.50/24 ipv4.gateway 192.168.122.1 ipv4.dns 8.8.8.8 ipv4.method manual connection.autoconnect yes
nmcli connection up enp1s0
Task 2: User and Group Administration

Bash


groupadd sysadmins
useradd -g sysadmins alice
useradd -G sysadmins -s /sbin/nologin bob
Task 3: Collaborative Directory (Permissions & SGID)

Bash


mkdir -p /shared/ops
chgrp sysadmins /shared/ops
chmod 2770 /shared/ops
Task 4: Access Control Lists (ACL)

Bash


useradd harry
setfacl -m u:harry:rw- /shared/ops
Task 5: Archiving and Compression

Bash


mkdir /root/log_archive
find /var/log -name "*.log" -size +1M -exec cp {} /root/log_archive/ \;
tar -cjvf /root/logs_backup.tar.bz2 /root/log_archive/
Task 6: Logical Volume Management (LVM)

Bash


pvcreate /dev/vdb
vgcreate -s 16M vg_app /dev/vdb
lvcreate -l 50 -n lv_data vg_app
mkfs.xfs /dev/vg_app/lv_data
mkdir -p /mnt/app_data
# Get the UUID:
blkid /dev/vg_app/lv_data
# Add to /etc/fstab:
# UUID=<your-uuid> /mnt/app_data xfs defaults 0 0
mount -a
Task 7: LVM Extension

Bash


lvextend -L 1.5G -r /dev/vg_app/lv_data
(Note: The -r flag is crucial as it resizes the XFS filesystem automatically).

Task 8: SELinux Port Contexts

Bash


# After installing httpd and modifying /etc/httpd/conf/httpd.conf to 'Listen 8282'
semanage port -a -t http_port_t -p tcp 8282
systemctl restart httpd
Task 9: SELinux File Contexts

Bash


mkdir -p /custom/www
touch /custom/www/index.html
semanage fcontext -a -t httpd_sys_content_t "/custom/www(/.*)?"
restorecon -Rv /custom/www
Task 10: Firewalld Configuration

Bash


firewall-cmd --permanent --add-port=8282/tcp
firewall-cmd --reload
