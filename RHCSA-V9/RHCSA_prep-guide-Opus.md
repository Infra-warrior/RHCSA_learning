-- BAsic of Linux Rapid R199 

22nd May --- 29th May

-- Opus Outcome:

Schedule as per OPUS
Day			Status		Study Window		Type

Sunday			OFF		8-10 Hrs		Deep Work- hardest topicx, new concepts

Monday			OFF		8-10 Hrs		Deep Work-labs,mock practice

Tuesday		Night Shift 		1.5 hrs			Light Revision only

Wednesday	Night Shift		1 hr			Flashcards, command drill

Thursday	Night Shift		1 hr			Flashcards, command drill

Friday		Night Shift		1.5 Hr			Single Focused lab

Saturday	Night Shift(last)	1.5 hrs			Catch-up + Sunday prep
----------------------------------------------------------------------------

Day 1 (Sunday) Lab Verification + SSH Mastery + ACLs

Morning(4hrs):
- Verify both RHEL 9 VMs boot, snapshot them as clean-baseline"
- Add 4 extra Virtual Disks to server1 (5GB each) -- you'll destroy these repeatedly
- SSH Key Drill (do 5 times in a row):
	1) ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
	2) ssh-copy-id root@server2
	3) ssh root@server2 'hostname'		#Must work without password
- ACL Lab-- repeat until automatic
	1) mkdir /shared
	2) groupadd ops
	3) useradd alice; useradd bob; usermod -aG ops alice
	4) setfacl -m u:bob:rwx /shared
	5) setfacl -m g:ops:rx /shared
	6) setfacl -d -m g:ops:rwx /shared  #default ACL
	7) getfacl /shared

Evening (4Hrs):
- Permission deep drill: Create scenarios for SUID/SGID/Sticky
	1) # SUID example
	2) chmod u+x /usr/bin/passwd	#Already has it -observe
	3) # SGID example for collaborative dir
	4) chmod g+s /shared		#New files inherit group
	5) # Sticky example
	6) chmod +t /tmp		#Only owner can delete

- Self-test: Without notes, set up /data/team where new files inherit ops group, alice has full ACL, bob has read-only. Get it right 3 times in a row. 

Day 2(Monday) -- STORAGE BOOTCAMP DAY 1: PArtitioning + Filesystem + fstab

Morning(4hrs):
- Reset server1 to baseline snapshot(you'll do this 20+ times this month)
- Drill 1: Create 1GB partition on dev/vdb using parted, GPT label
- Drill 2: Create same with fdisk
- Drill 3: Delete + recreate 3 times untill you don't need to think
	1) parted /dev/vdb mklabel gpt
	2) parted /dev/vdb mkpart primary 1MiB 1025MiB
	3) parted /dev/vdb print
	4) partprobe			#Important -- refresh kernel
	5) lsblk
Afternoon(4hrs)-- fstab MAstery (The Killer topic)
- Format the partition as XFS, then ext4 (do both)
- The Sacred fstab Procedure(memorizze this order):
	1) # Step 1 -- Get UUID (Never use device name in fstab!)
	2) blkid /dev/vdb1

	3) # Step 2 -- Create mount point
	4) mkdir -p /data/logs
	
	5) # Step 3 -- Add to fstab using UUID	
	6) echo "UUID=<paste-uuid> /data/logs	xfs	defaults	0 0" >> /etc/fstab


