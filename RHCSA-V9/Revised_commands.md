man -k 
/-P
whatis
{command} --help | grep {keyword}

Domain:1 Essential System & File Management

---Archiving & Compression (tar): Know how to group files and compress them using gzip (-z) and bzip2 (-j).

	Create: tar -czvf /path/to/backup.tar.gz /target/directory

	Extract: tar -xzvf /path/to/backup.tar.gz -C /extract/destination

File Locating (find): Finding files based on size, name, or permissions, and executing actions on them.

	Key Command: find /var/log -name "*.log" -size +1M -exec cp {} /backup/ \;

Text Filtering (grep): Searching files for specific strings (often used for log auditing).

	Key Command: grep -i "failed" /var/log/secure > /root/failures.txt

Domain 2: User & Access Management
Creating accounts, granting temporary admin rights, and locking down folders.

User & Group Creation: Creating users, assigning primary/secondary groups, and setting non-interactive shells.

	Key Commands: groupadd, useradd -G groupname -s /sbin/nologin username, passwd

Sudoers (visudo): Allowing specific users to run commands as root without a password.

	Key Location: /etc/sudoers.d/custom_file

	Syntax: username ALL=(ALL) NOPASSWD: ALL

Advanced Permissions (SGID & ACLs): Forcing group inheritance on directories and giving specific users access without putting them in a group.

	SGID: chmod 2770 /shared_folder

	Set ACL: setfacl -m u:username:rwx /shared_folder

	Default ACL (for future files): setfacl -d -m u:username:rwx /shared_folder

Domain 3: Networking & Firewalls
Connecting the server to the world and protecting the perimeter.

NetworkManager (nmcli): Setting static IPs, gateways, DNS, and ensuring they start on boot.

	Key Command: nmcli connection modify "eth0" ipv4.addresses 10.0.0.5/24 ipv4.gateway 10.0.0.1 ipv4.dns 8.8.8.8 ipv4.method manual connection.autoconnect yes

	Apply: nmcli connection up "eth0"

Firewalld: Opening specific ports or services permanently.

	Key Command: firewall-cmd --permanent --add-port=8080/tcp

	Apply: firewall-cmd --reload

Domain 4: Storage Engineering (The Heavyweight)
This is the most critical part of the exam. You must master LVM.

Logical Volume Management (LVM): Creating physical volumes, volume groups, and logical volumes.

	Key Commands: pvcreate /dev/sdb, vgcreate -s 16M vg_name /dev/sdb, lvcreate -l 50 -n lv_name vg_name

Filesystems & Mounting: Formatting the volume and making it persistent in /etc/fstab.

	Format: mkfs.xfs /dev/vg_name/lv_name or mkfs.ext4 /dev/vg_name/lv_name

	Fstab Entry: UUID=1234... /mnt/data xfs defaults 0 0

Live Extension (lvextend): Growing a volume and its filesystem simultaneously.

	Key Command: lvextend -L 2G -r /dev/vg_name/lv_name (The -r resizes the filesystem natively!)

Swap Space: Creating dedicated virtual memory.

	Key Commands: lvcreate -L 512M -n lv_swap vg_name, mkswap /dev/vg_name/lv_swap, swapon -a

Domain 5: Dynamic Storage (AutoFS)
Mounting drives only when a user looks for them.

AutoFS Configuration: Linking a master watcher to a specific map file.

	Master (/etc/auto.master): /shares /etc/auto.custom

	Map (/etc/auto.custom): marketing -fstype=bind :/opt/marketing_data

Rule of Thumb: Never manually create the target directory (/shares/marketing). Let AutoFS do it.

Domain 6: SELinux (Security Enhanced Linux)
Appeasing the internal bouncer.

File Contexts: Telling SELinux a custom folder is allowed to be served by a service (like Apache).

	Key Command: semanage fcontext -a -t httpd_sys_content_t "/custom_www(/.*)?"

	Apply: restorecon -Rv /custom_www

Port Contexts: Telling SELinux a service is allowed to use a non-standard port.

	Key Command: semanage port -a -t http_port_t -p tcp 8181

Booleans: Flipping native SELinux switches (e.g., allowing web servers to connect to databases).

	Key Command: setsebool -P httpd_can_network_connect 1

Domain 7: Repositories & Automation
Installing software and scheduling jobs.

YUM/DNF Repositories: Creating a .repo file to point the system to a local software host.

	Key Location: /etc/yum.repos.d/custom.repo

	Required Fields: [ID], name=, baseurl=, enabled=1, gpgcheck=0

Cron Jobs: Scheduling recurring system tasks.

	Key Command: crontab -e

Syntax: Minute Hour DayOfMonth Month DayOfWeek /path/to/command

Domain 8: Containerization (Podman - RHEL 9 Standard)
Running rootless micro-services.

Running Containers: Pulling an image and mapping ports.

	Key Command: podman run -d --name myweb -p 8080:80 docker.io/library/nginx

Systemd Persistence: Ensuring the container boots with the system as a user service.

	Step 1 (Root): loginctl enable-linger student

	Step 2 (User): mkdir -p ~/.config/systemd/user/ ; cd ~/.config/systemd/user/

	Step 3 (User): podman generate systemd --new --files --name myweb

	Step 4 (User): systemctl --user enable --now container-myweb.service

Domain 9: System Recovery
Breaking back into your own machine.

	Root Password Reset: Interrupting GRUB and remounting the system.

	Append rd.break to the kernel line at boot.

	mount -o remount,rw /sysroot

	chroot /sysroot

	passwd

	touch /.autorelabel (If you forget this, SELinux will break your system on reboot!)
