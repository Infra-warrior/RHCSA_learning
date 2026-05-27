The Multi-Node Practice Exam

🖥️ Tasks on workstation (The Command Center)
Log in here as your standard user to set up your automation anchor.

Task 1: Automated Access Link
Generate an SSH key-pair on workstation. Configure the environment so you can SSH into servera, serverb, and serverc as the student user without ever being prompted for a password. Do not modify the root SSH configurations directly.

-- ssh-keygen -t rsa -b 4096 -C "your_email@example.com" //why example.com, is it a persnol email or hostname
-- home/student/.ssh/id_rsa.pub //public key
-- ssh-copy-id student@servera //got the error that All keys were skipped because they already exist on the remote system. 

Question, does the ssh-copy picks the pub file automatically?
DO I need to copy the ssh id to each server in seprate command or can I use it as sudent@servea student@serverb and so on?


🖥️ Tasks on servera (System & Security Operations)
SSH from workstation into servera and elevate to root to perform these tasks.

Task 2: Interface Configuration
Modify the primary network interface on servera to ensure it dynamically maps its IP via DHCP, but manually append a 
secondary DNS search domain pointing to exam.internal. Ensure the interface automatically activates on system boot.

1) nmcli connection show //list and find the connection to modify
2) nmcli connection modify "name of connection" +ipv4.dns-search "exam.internal"
3) sudo nmcli connection modify "YOUR_CONNECTION_NAME" connection.autoconnect yes
4) sudo nmcli connection down "YOUR_CONNECTION_NAME" && sudo nmcli connection up "YOUR_CONNECTION_NAME"
5) sudo nmcli connection show "YOUR_CONNECTION_NAME" | grep dns-search

Now help me understand each of the steps in details, specially the 2nd step +ipv4, what if I change it to ipv6, will that change the outcome?

Task 3: Collaborative Admin Workspace
Create a local OS group named sysops. Create two users: manager (with a default shell) and operator (strictly non-interactive shell). Add both users to sysops as a secondary group.

1)sudo groupadd sysops
2)sudo useradd -m -s /bin/bash -G sysops manager
3) sudo useradd -m -s /usr/sbin/nologin -G sysops operator1  // As operator already exist. 


Task 4: Shared Directory Hardening
Create a directory at /opt/production. Implement a security schema using native octal permissions so that:

The root user and members of sysops have complete read, write, and execute permissions.

Unprivileged system users (others) have absolute zero access.

Any new subdirectories or files created within this path immediately inherit the sysops group ID via SGID.

Task 5: Precision Auditing Tasks
Configure a recurring system task for the root user. The task must execute every Monday and Thursday at exactly 4:15 AM, appending the current system disk usage data (df -h) into a file located at /var/log/disk_audit.log.


.

🖥️ Tasks on serverb (Storage & Automation Engineering)
SSH from workstation into serverb and elevate to root.

Task 6: The LVM Real-Estate Build
The system has an unallocated secondary block storage device available (identify it using lsblk). Create a Volume Group named vg_store with a Physical Extent (PE) allocation size of 8MB. Inside this group, provision a Logical Volume named lv_media with a total size of 1.2GB. Format it as ext4 and map it persistently via UUID to mount at /mnt/media.

Task 7: Emergency Storage Injection
Your core services are hitting a wall. Dynamically extend the newly created lv_media volume to a total capacity of 2.0GB. Ensure that the underlying ext4 filesystem expands live alongside the block layer without unmounting the path.

Task 8: Virtual Memory (Swap) Expansion
Provision an additional 512MB Logical Volume named lv_swap inside vg_store. Initialize it cleanly as system swap space, ensure it mounts persistently across system reboots, and activate it immediately.

Task 9: Reactive Autofs Drives
Configure the automounter system to dynamically mount a directory. When a user navigates to /shares/marketing, the system must automatically bind-mount the local directory /opt/marketing_data. Ensure the service is configured to automatically boot on system initialization.

🖥️ Tasks on serverc (Modern App Deployments)
SSH from workstation into serverc and elevate to root.

Task 10: Non-Standard Web Binding
Install the web engine package (httpd or nginx). Modify its native configuration file to drop port 80 and instead listen on port 8181.

Task 11: SELinux Security Bypass Prevention
If you try to start the web engine now, SELinux will kill the process. Use the appropriate tools to update the SELinux policy database to allow the web service to cleanly bind to port 8181. Do not set SELinux to permissive mode.

Task 12: Network Perimeter Control
Configure the host firewall to permanently accept incoming TCP traffic on port 8181. Ensure you do not disrupt default zones or active connections. Reload the subsystem and verify the rules are active.

Task 13: Standard Container Deployment
Switch to your student user account on serverc. Deploy a rootless container instance running an nginx:latest image. Map host port 8080 directly to container port 80. Ensure the container engine is configured to launch this container automatically as a systemd user service every time serverc boots up, without requiring an active user login session.

