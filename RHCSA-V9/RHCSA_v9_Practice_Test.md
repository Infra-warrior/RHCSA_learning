# RHCSA v9 (EX200) Mock Practice Test
## TechCorp Delhi Infrastructure Setup Scenario

**Exam Format:** Performance-Based Hands-On  
**Duration:** 3 Hours (180 minutes)  
**Total Tasks:** 15  
**Passing Score:** 210/300 points (70%)  
**Point Distribution:** ~20 points per task

---

## 📋 SCENARIO BRIEFING

You are a Linux System Administrator hired by **TechCorp Delhi**, a mid-size IT company. The company is migrating their legacy infrastructure to a modern RHEL 9 environment. Your task is to configure a new production server that will host:

1. Company web application (running on custom port)
2. NFS file sharing for development teams
3. Performance-optimized database workloads
4. Regular data backups

**Important Notes:**
- All configurations must **persist after reboot**
- All tasks must be completed without assistance
- Internet access is **NOT** available during the exam
- Document any issues encountered
- Time management: allocate 7-10 minutes per task

---

## 🚀 SYSTEM STARTUP & PREPARATION (Informational)

**Server Details:**
- Hostname: `prodserver01.techcorp.local`
- Base OS: Red Hat Enterprise Linux 9
- Available storage: 100GB (with 50GB additional unallocated)
- Network interface: ens33 (connected to corporate LAN)
- SELinux: Enforcing mode

**Initial System State:**
- Root password: `RedHat@123` (you have this for recovery)
- Repositories: Default RHEL repositories configured
- Additional repos needed: Will be provided in Task 5

---

## 📝 TASK BREAKDOWN

### **PHASE 1: NETWORK & SYSTEM CONFIGURATION** (Tasks 1-3)

---

### **TASK 1: Network Configuration with Static IP**
**Estimated Time:** 10 minutes | **Points:** 20

**Objective:**  
Configure the system with a static IPv4 address and proper hostname. The system must be reachable on the corporate network.

**Requirements:**
1. Set hostname to `prodserver01.techcorp.local`
2. Configure network interface `ens33` with:
   - Static IP: `192.168.1.150/24`
   - Gateway: `192.168.1.1`
   - Primary DNS: `8.8.8.8`
   - Secondary DNS: `1.1.1.1`
   - DNS search domain: `techcorp.local`
3. Ensure connectivity to gateway and DNS is working
4. Verify configuration persists after system reboot

**Verification Checklist:**
- [ ] `hostname` command shows `prodserver01.techcorp.local`
- [ ] `ip a` shows 192.168.1.150/24 on ens33
- [ ] `ping 192.168.1.1` responds
- [ ] `nslookup 8.8.8.8` works
- [ ] Configuration survives reboot

**Hints:**
- Use `nmcli` or edit NetworkManager config files directly
- Check `/etc/NetworkManager/conf.d/` for settings
- Use `hostnamectl` for hostname configuration

---

### **TASK 2: SSH Server Hardening**
**Estimated Time:** 10 minutes | **Points:** 20

**Objective:**  
Configure SSH for secure remote access with key-based authentication disabled for password attacks.

**Requirements:**
1. SSH server listens on **port 2222** (non-standard, for security)
2. Disable **password-based authentication**
3. Disable **root login** via SSH
4. Enable **key-based authentication** only
5. Ensure SSH service starts automatically on boot
6. Test SSH connectivity (you should be able to connect as regular user)

**Verification Checklist:**
- [ ] `/etc/ssh/sshd_config` shows `Port 2222`
- [ ] PasswordAuthentication is disabled
- [ ] PermitRootLogin is disabled
- [ ] PubkeyAuthentication is enabled
- [ ] SSH service is enabled (`systemctl is-enabled ssh`)
- [ ] `systemctl status sshd` shows active

**Hints:**
- Edit `/etc/ssh/sshd_config` directly with `nano` or `vi`
- Reload SSH service: `systemctl reload sshd`
- Verify syntax: `sshd -t`
- Default SSH port is 2222; firewall may need update (Task 10)

---

### **TASK 3: Firewall Configuration**
**Estimated Time:** 8 minutes | **Points:** 15

**Objective:**  
Enable and configure firewalld to allow necessary services while maintaining security.

**Requirements:**
1. Ensure `firewalld` service is **started and enabled**
2. Open ports:
   - SSH: **2222/tcp** (custom port from Task 2)
   - HTTP: **80/tcp**
   - HTTPS: **443/tcp**
   - NFS: **2049/tcp and 2049/udp** (for Task 11)
3. Make all rules **permanent**
4. Reload firewall to activate rules
5. Verify all ports are open

**Verification Checklist:**
- [ ] `firewall-cmd --list-ports` shows all required ports
- [ ] `firewall-cmd --list-services` shows 'nfs' if using services
- [ ] Rules persist after reboot
- [ ] Can test with `netstat -tuln` or `ss -tuln`

**Hints:**
- Use `firewall-cmd --permanent --add-port=PORT/PROTOCOL`
- Alternative: `firewall-cmd --permanent --add-service=SERVICE`
- Don't forget `firewall-cmd --reload` after changes

---

## **PHASE 2: USER MANAGEMENT & ACCESS CONTROL** (Tasks 4-6)

---

### **TASK 4: Create Custom User with Special Permissions**
**Estimated Time:** 12 minutes | **Points:** 20

**Objective:**  
Create a service account for the web application with precise privilege escalation.

**Requirements:**
1. Create user: `webapp_svc`
2. User details:
   - Primary group: Create a group `webapps` and add user to it
   - Home directory: `/opt/webapp_home`
   - Shell: `/sbin/nologin` (service account, no interactive login)
   - Password: Generate and set to `WebApp@2024`
3. Configure sudo access:
   - User can restart Apache service (`systemctl restart httpd`)
   - User can edit Apache config (`/etc/httpd/conf/httpd.conf`)
   - **NO password required** for these commands (passwordless sudo)
   - User cannot use other sudo commands
4. Create home directory with proper ownership
5. Verify user exists in `/etc/passwd` and group in `/etc/group`

**Verification Checklist:**
- [ ] `grep webapp_svc /etc/passwd` shows user exists
- [ ] `grep webapps /etc/group` shows group exists
- [ ] `/opt/webapp_home` directory exists with correct ownership
- [ ] `sudo -u webapp_svc sudo -l` shows allowed commands
- [ ] Sudo commands can be executed without password

**Hints:**
- Use `useradd` with `-g`, `-d`, `-s` flags
- Create group first: `groupadd webapps`
- Edit `/etc/sudoers` with `visudo` (never edit directly!)
- Sudoers syntax: `webapp_svc ALL=(ALL) NOPASSWD: /bin/systemctl restart httpd, /bin/nano /etc/httpd/conf/httpd.conf`

---

### **TASK 5: Repository Configuration & Custom Repository**
**Estimated Time:** 8 minutes | **Points:** 15

**Objective:**  
Configure access to a custom company repository for proprietary tools.

**Requirements:**
1. Verify default RHEL repositories are configured and accessible
2. Create a custom repository entry for company tools:
   - Repository ID: `techcorp-custom`
   - Name: `TechCorp Custom Tools`
   - Base URL: `https://repo.techcorp.local/rhel/9/custom/x86_64/`
   - GPG Check: Disabled (for test environment)
   - Enabled: Yes
   - Priority: 10
3. Test repository availability: `dnf repolist`
4. Verify you can list packages from custom repo

**Verification Checklist:**
- [ ] `dnf repolist all` shows both default and custom repos
- [ ] `/etc/yum.repos.d/techcorp-custom.repo` exists
- [ ] `dnf search` works with custom repo
- [ ] No permission errors when accessing repo

**Hints:**
- Create repo config: `/etc/yum.repos.d/techcorp-custom.repo`
- Format:
  ```
  [techcorp-custom]
  name=TechCorp Custom Tools
  baseurl=https://repo.techcorp.local/rhel/9/custom/x86_64/
  enabled=1
  gpgcheck=0
  priority=10
  ```
- Verify with `dnf repolist` or `yum repolist`

---

### **TASK 6: Root Password Recovery (Troubleshooting)**
**Estimated Time:** 10 minutes | **Points:** 20

**Objective:**  
Demonstrate ability to recover system access if root password is forgotten (common emergency scenario).

**Requirements:**
1. Simulate lost root password scenario
2. Boot into emergency/rescue mode
3. Mount root filesystem read-write
4. Reset root password to: `NewRootPass@2024`
5. Return to normal mode
6. Verify new password works
7. Document the procedure

**Verification Checklist:**
- [ ] Can login as root with new password
- [ ] System boots normally
- [ ] All previous configurations still intact
- [ ] Able to execute root commands

**Hints:**
- Interrupt GRUB boot (hold SHIFT or ESC during startup)
- Edit GRUB kernel parameters: add `rd.break` or use rescue mode
- Mount: `mount -o remount,rw /sysroot`
- Change root: `chroot /sysroot`
- Reset password: `passwd root`
- Type `exit` twice to continue booting

**Note:** This is an emergency procedure. In production, document all root passwords in secure vaults!

---

## **PHASE 3: STORAGE, LVM & MOUNTING** (Tasks 7-9)

---

### **TASK 7: LVM Creation and Configuration**
**Estimated Time:** 15 minutes | **Points:** 25

**Objective:**  
Create and configure Logical Volume Management for scalable storage.

**Requirements:**
1. Identify the unallocated 50GB storage device (likely `/dev/sdb`)
2. Create partition on `/dev/sdb`:
   - Size: 45GB
   - Type: GPT (not MBR)
   - Use `gdisk` or `parted`
3. Create Physical Volume (PV):
   - Device: `/dev/sdb1`
   - Name: Show with `pvs`
4. Create Volume Group (VG):
   - Name: `appdata_vg`
   - Add PV `/dev/sdb1` to it
   - Verify with `vgs`
5. Create Logical Volume (LV):
   - Name: `appdata_lv`
   - Size: 40GB
   - File system: **XFS**
6. Mount configuration:
   - Mount point: `/data/appdata`
   - Mount type: Permanent (in `/etc/fstab`)
   - Use **UUID** (not device name) in fstab
   - Mount options: `defaults`
7. Verify mount persists after reboot

**Verification Checklist:**
- [ ] `pvs` shows `/dev/sdb1`
- [ ] `vgs` shows `appdata_vg`
- [ ] `lvs` shows `appdata_lv` in `appdata_vg`
- [ ] `mount | grep /data/appdata` shows XFS mount
- [ ] `/etc/fstab` contains correct UUID entry
- [ ] `df -h | grep appdata` shows 40GB mounted
- [ ] Survives reboot

**Hints:**
- Create partition: `sudo gdisk /dev/sdb` → `n` → set size to `+45G`
- List devices: `lsblk` or `fdisk -l`
- Get UUID: `blkid /dev/appdata_vg/appdata_lv`
- Mount options: `mount /data/appdata` and verify with `mount | tail -1`

---

### **TASK 8: Extending LVM and Swap Creation**
**Estimated Time:** 12 minutes | **Points:** 20

**Objective:**  
Extend existing logical volume and create swap space for system stability.

**Requirements:**
1. Extend `appdata_lv` by additional **5GB** (from 40GB to 45GB)
   - Without unmounting the file system
   - Using XFS file system growth
2. Create **2GB swap** space:
   - Create new logical volume: `swap_lv` in `appdata_vg`
   - Initialize as swap: `mkswap`
   - Add to `/etc/fstab` with UUID
   - Enable swap immediately: `swapon`
3. Verify swap is active

**Verification Checklist:**
- [ ] `lvs` shows `appdata_lv` is now 45GB
- [ ] `df -h | grep appdata` shows increased size
- [ ] `lvs` shows `swap_lv` of 2GB
- [ ] `swapon --show` shows active swap
- [ ] `free -h` shows swap available
- [ ] Both survive reboot

**Hints:**
- Extend LV: `lvextend -L +5G /dev/appdata_vg/appdata_lv`
- Grow XFS: `xfs_growfs /data/appdata`
- For ext4, use: `resize2fs /dev/appdata_vg/appdata_lv`
- Create swap: `lvcreate -L 2G -n swap_lv appdata_vg`
- Initialize: `mkswap /dev/appdata_vg/swap_lv`
- Fstab entry: `UUID=xxxx none swap sw 0 0`

---

### **TASK 9: Auto-Mounting with Auto-Mount (autofs)**
**Estimated Time:** 10 minutes | **Points:** 15

**Objective:**  
Configure automatic mounting of network shares on-demand to save system resources.

**Requirements:**
1. Install `autofs` package
2. Configure direct autofs mount for `/nfs/archive`:
   - Mounts remote NFS path: `nfs.techcorp.local:/exports/archive`
   - Mount point: `/nfs/archive`
   - Automount options: `soft,intr,rw`
3. Auto-unmount after 5 minutes of inactivity
4. Enable autofs service on boot
5. Test the automount (it will mount when accessed)

**Verification Checklist:**
- [ ] `dnf list installed | grep autofs`
- [ ] `/etc/auto.master` contains entry
- [ ] `/etc/auto.direct` (or similar) configured
- [ ] `systemctl is-enabled autofs` shows enabled
- [ ] `/nfs/archive` available (may appear empty initially)
- [ ] Access `/nfs/archive` triggers mount

**Hints:**
- Install: `sudo dnf install -y autofs`
- Edit `/etc/auto.master`: add `/- /etc/auto.direct`
- Edit `/etc/auto.direct`: `/nfs/archive -soft,intr,rw nfs.techcorp.local:/exports/archive`
- Reload: `systemctl reload autofs`
- Test: `ls -la /nfs/archive/` should trigger mount
- Check with: `mount | grep nfs`

---

## **PHASE 4: NFS & SHARED STORAGE** (Task 10)

---

### **TASK 10: Configure NFS Server**
**Estimated Time:** 12 minutes | **Points:** 20

**Objective:**  
Set up NFS file server for development team collaboration.

**Requirements:**
1. Install NFS packages: `nfs-utils`
2. Create export directories:
   - `/export/projects` (for development files)
   - `/export/backups` (for backup storage)
3. Configure NFS exports in `/etc/exports`:
   - `/export/projects`: Export to `192.168.1.0/24` with `rw,sync,no_root_squash`
   - `/export/backups`: Export to `192.168.1.100` (single IP) with `rw,sync,root_squash`
4. Set proper permissions:
   - `/export/projects`: Owner `root`, Group `developers`, Permissions `0775`
   - `/export/backups`: Owner `root`, Group `backup`, Permissions `0755`
5. Enable and start NFS services:
   - `nfs-server`
   - `nfs-mountd`
   - `rpc-statd`
6. Reload NFS exports: `exportfs -r`
7. Verify exports: `exportfs -v`

**Verification Checklist:**
- [ ] `rpm -q nfs-utils` shows installed
- [ ] `/export/projects` and `/export/backups` directories exist
- [ ] `/etc/exports` contains both shares
- [ ] `exportfs -v` shows both exports active
- [ ] `showmount -e localhost` shows exports
- [ ] NFS ports open in firewall (already done in Task 3)
- [ ] Services enabled and running

**Hints:**
- Syntax in `/etc/exports`: `path host(options) [host(options)]`
- Create groups if needed: `groupadd developers`, `groupadd backup`
- Set ownership: `chown -R root:developers /export/projects`
- Reload: `systemctl restart nfs-server`
- Verify: `systemctl status nfs-server`

---

## **PHASE 5: SECURITY & SELinux** (Tasks 11-12)

---

### **TASK 11: SELinux Port Mapping**
**Estimated Time:** 10 minutes | **Points:** 20

**Objective:**  
Configure SELinux to allow web server on non-standard port with proper context.

**Requirements:**
1. You will configure Apache to run on **port 8090** (Task 13)
2. Tell SELinux Apache can bind to port 8090:
   - Use `semanage port` command
   - Type: `http_port_t`
   - Protocol: tcp
   - Port: 8090
3. Verify the port mapping is persistent
4. Check with: `semanage port -l | grep http_port_t`

**Verification Checklist:**
- [ ] `semanage port -l | grep 8090` shows `8090/tcp`
- [ ] SELinux denial log shows no errors for port 8090
- [ ] Setting persists after reboot

**Hints:**
- Command: `sudo semanage port -a -t http_port_t -p tcp 8090`
- Verify: `sudo semanage port -l | grep http_port_t | grep 8090`
- Check denials: `sudo ausearch -m avc | grep http | tail -10`

---

### **TASK 12: SELinux File Context Management**
**Estimated Time:** 12 minutes | **Points:** 20

**Objective:**  
Configure SELinux contexts for web content in custom directory.

**Requirements:**
1. The web app will serve files from `/data/webroot` (you create this)
2. Create directory: `/data/webroot` with ownership `root:webapps`
3. Add SELinux file context rule:
   - Directory: `/data/webroot`
   - Type: `httpd_sys_content_t`
   - Include all subdirectories with regex: `/data/webroot(/.*)? `
4. Verify context rule is saved to database
5. Apply contexts to files immediately: `restorecon -Rv`
6. Verify file contexts show correct type

**Verification Checklist:**
- [ ] `semanage fcontext -l | grep webroot` shows rule
- [ ] `ls -Z /data/webroot` shows `httpd_sys_content_t` context
- [ ] No SELinux denials in logs
- [ ] Contexts persist after reboot

**Hints:**
- Create rule: `sudo semanage fcontext -a -t httpd_sys_content_t "/data/webroot(/.*)?"`
- Apply labels: `sudo restorecon -Rv /data/webroot`
- View contexts: `ls -Z /data/webroot` or `stat /data/webroot`
- Check denials: `sudo tail -f /var/log/audit/audit.log` (if running)

---

## **PHASE 6: SYSTEM SERVICES & PERFORMANCE** (Tasks 13-14)

---

### **TASK 13: Configure Apache Web Server on Custom Port**
**Estimated Time:** 10 minutes | **Points:** 20

**Objective:**  
Deploy web server on non-standard port with custom document root.

**Requirements:**
1. Install Apache: `httpd`
2. Configure Apache:
   - Listen port: **8090** (instead of default 80)
   - Document root: `/data/webroot`
   - Create DocumentRoot directory with sample index.html
3. Set file ownership: `root:webapps`
4. File permissions: `/data/webroot` is `0755`
5. Service configuration:
   - Enable httpd to start on boot
   - Start the service
6. Test connectivity:
   - Service should be running
   - Port 8090 should be open (firewall done in Task 3)
   - curl localhost:8090 should return index.html

**Verification Checklist:**
- [ ] `rpm -q httpd` shows installed
- [ ] `/etc/httpd/conf/httpd.conf` shows `Listen 8090`
- [ ] `/etc/httpd/conf/httpd.conf` shows correct DocumentRoot
- [ ] `/data/webroot` exists with index.html
- [ ] `systemctl is-enabled httpd` shows enabled
- [ ] `systemctl status httpd` shows active
- [ ] `curl http://localhost:8090` returns content

**Hints:**
- Install: `sudo dnf install -y httpd`
- Edit config: `sudo nano /etc/httpd/conf/httpd.conf`
- Change: `Listen 80` → `Listen 8090`
- Change: `DocumentRoot "/var/www/html"` → `DocumentRoot "/data/webroot"`
- Create index.html: `echo "TechCorp - Production Server" | sudo tee /data/webroot/index.html`
- Start: `sudo systemctl enable --now httpd`

---

### **TASK 14: Performance Tuning with Tuned**
**Estimated Time:** 8 minutes | **Points:** 15

**Objective:**  
Optimize system performance for database workloads.

**Requirements:**
1. Install tuned performance service
2. Enable tuned to auto-start
3. Set performance profile to: `throughput-performance`
   - This profile optimizes for high-throughput workloads
   - Disables power management
   - Increases CPU frequency
4. Verify active profile
5. Make changes persistent
6. Create custom tuned profile with:
   - Name: `techcorp-db`
   - Based on `throughput-performance`
   - Additional setting: disable `transparent_hugepage`

**Verification Checklist:**
- [ ] `rpm -q tuned` shows installed
- [ ] `systemctl is-enabled tuned` shows enabled
- [ ] `tuned-adm active` shows active profile
- [ ] `/etc/tuned/techcorp-db/` directory created
- [ ] `/etc/tuned/techcorp-db/tuned.conf` exists
- [ ] `tuned-adm profile techcorp-db` activates custom profile

**Hints:**
- Install: `sudo dnf install -y tuned`
- Enable: `sudo systemctl enable tuned`
- List profiles: `tuned-adm list`
- Set profile: `sudo tuned-adm profile throughput-performance`
- Verify: `tuned-adm active` or `cat /etc/tuned/active_profile`
- Custom profile template:
  ```
  [main]
  include=throughput-performance
  
  [vm]
  transparent_hugepage=never
  ```

---

## **PHASE 7: DATA MANAGEMENT** (Task 15)

---

### **TASK 15: Archive, Compress, and File Management**
**Estimated Time:** 10 minutes | **Points:** 20

**Objective:**  
Create and manage data archives for backup and distribution.

**Requirements:**
1. Create sample data in `/data/appdata` directory:
   - Create 5 empty log files: `app.log`, `error.log`, `debug.log`, `access.log`, `security.log`
   - Create subdirectory: `database/` with 3 sample SQL files
2. Archive operations:
   - Create **gzip tarball**: `/backups/appdata_backup_$(date +%Y%m%d).tar.gz`
   - Archive entire `/data/appdata` directory
   - Use verbose output to verify files
3. Compression bonus:
   - Create **bzip2** compressed archive of just log files
   - Destination: `/backups/logs_backup.tar.bz2`
4. Test extraction:
   - Extract gzip archive to `/tmp/restore_test/`
   - Verify all files restore correctly
5. File redirection & grep:
   - List all log files from tarball contents: `tar -tzf backup.tar.gz | grep '.log'`
   - Count log files: `tar -tzf backup.tar.gz | grep -c '.log'`

**Verification Checklist:**
- [ ] `/backups/` directory exists
- [ ] `appdata_backup_*.tar.gz` file created
- [ ] Tarball contains all files: `tar -tzf backup.tar.gz`
- [ ] `logs_backup.tar.bz2` created with compression
- [ ] Extract test succeeds: `tar -xzf backup.tar.gz -C /tmp/restore_test/`
- [ ] Grep filters correctly: shows only `.log` files
- [ ] Log count accurate

**Hints:**
- Create logs: `touch /data/appdata/{app,error,debug,access,security}.log`
- Create dir: `mkdir -p /data/appdata/database` and add sample files
- Tar with date: `tar -czvf /backups/appdata_backup_$(date +%Y%m%d).tar.gz /data/appdata`
- View tarball: `tar -tzf backup.tar.gz`
- Extract: `tar -xzf backup.tar.gz -C /tmp/restore_test/`
- Grep in tarball: `tar -tzf backup.tar.gz | grep '.log'`
- Bzip2: `tar -cjvf /backups/logs_backup.tar.bz2 /data/appdata/*.log`
- Output redirection: `tar -tzf backup.tar.gz > /tmp/file_list.txt`

---

## 🎯 EXAM COMPLETION CHECKLIST

After completing all 15 tasks, verify:

- [ ] **Persistence Verified:** Reboot the system and check all configurations survive
- [ ] **Network:** Can ping gateway, DNS resolves correctly
- [ ] **SSH:** Can login on port 2222 (if setup allows)
- [ ] **Storage:** All mounts show in `mount` command
- [ ] **Services:** Apache running on 8090, NFS exported, autofs responding
- [ ] **SELinux:** No denial errors in audit logs
- [ ] **Performance:** Tuned profile active
- [ ] **Backups:** All archives created and extractable

---

## ⏱️ TIME ALLOCATION GUIDE

| Phase | Tasks | Suggested Time |
|-------|-------|-----------------|
| Network & System | 1-3 | 28 minutes |
| Users & Repos | 4-6 | 40 minutes |
| Storage & LVM | 7-9 | 37 minutes |
| Security | 10-12 | 42 minutes |
| Services | 13-14 | 18 minutes |
| Data Mgmt | 15 | 10 minutes |
| **Review & Testing** | — | **5 minutes** |
| **Total** | **15** | **180 minutes** |

---

## 📚 REFERENCE MATERIALS AVAILABLE DURING EXAM

- Red Hat Enterprise Linux documentation (usually available)
- Manual pages (man pages): `man command-name`
- System help: `command --help`

**NOT Available:**
- Internet access
- External notes or books
- Pre-written scripts
- Communication with others

---

## ✅ SUCCESS TIPS

1. **Read each task 2-3 times** before starting
2. **Time-box each task:** If stuck >10 minutes, move to next
3. **Test everything:** Don't assume it works; verify each step
4. **Check persistence:** Reboot before marking task complete
5. **Use verbose flags:** `-v` shows what's happening
6. **Read error messages:** They tell you what's wrong
7. **Document issues:** Note problems for answer review

---

**Good luck! You've got this! 🎓**

*Remember: The exam tests your ability to solve real-world problems, not memorization. Think like a production sysadmin, not a test-taker.*
