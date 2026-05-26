Task 1: Network Configuration
Configure the network interface enp1s0 (or your primary interface) with the static IP address 192.168.122.50/24. Set the gateway to 192.168.122.1 and the DNS server to 8.8.8.8. Ensure the connection starts automatically on boot.

Task 2: User and Group Administration
Create a group named sysadmins. Create a user named alice with sysadmins as her primary group. Create a user named bob who belongs to the sysadmins group as a supplementary group. Ensure bob has a non-interactive shell.

Task 3: Collaborative Directory (Permissions & SGID)
Create a directory at /shared/ops. Ensure that the sysadmins group owns the directory. Configure the permissions so that the owner and group have full read/write/execute access, but others have no access. Ensure that any new files created inside this directory automatically inherit the sysadmins group ownership.

Task 4: Access Control Lists (ACL)
The user harry (create this user) needs read and write access to the /shared/ops directory, but he should not be added to the sysadmins group. Use an ACL to grant harry rw- access to the directory.

Task 5: Archiving and Compression
Find all files in the /var/log directory that end with .log and are larger than 1MB. Copy them to /root/log_archive/ (create the directory if needed). Then, compress the /root/log_archive/ directory into a bzip2-compressed tarball located at /root/logs_backup.tar.bz2.

Task 6: Logical Volume Management (LVM)
Add a new 5GB disk to your virtual machine (e.g., /dev/vdb). Create a Volume Group named vg_app with a physical extent size of 16MB. Create a Logical Volume named lv_data that is exactly 50 extents in size. Format it with the XFS filesystem and mount it persistently by UUID to /mnt/app_data.

Task 7: LVM Extension
Your previously created volume lv_data is running out of space. Extend it to a total size of 1.5GB, and ensure the underlying XFS filesystem is resized to match.

Task 8: SELinux Port Contexts
Configure the Apache HTTP Server (httpd) to listen on non-standard port 8282. Ensure SELinux allows Apache to bind to this port permanently.

Task 9: SELinux File Contexts
Create a directory at /custom/www and place an index.html file inside it. Configure SELinux so that the Apache service is permitted to serve files from this directory. Ensure the changes survive a filesystem relabel.

Task 10: Firewalld Configuration
Configure the system firewall to permanently allow traffic on your custom Apache port (8282/tcp). Ensure the change is active immediately.
