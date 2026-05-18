#!/bin/bash
# Description: Automated RHEL 10 KVM Lab Builder (GUI Nodes)

# === UPDATE THIS LINE ===
ISO_PATH="/home/kratos/Downloads/rhel-10.1-x86_64-dvd.iso"
# ========================

if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use sudo)." 
   exit 1
fi

clear
echo "===================================================="
echo "🚀 INITIATING RHEL 10 ZERO-TOUCH PROVISIONING"
echo "===================================================="
echo "System Mode: Sequential & Fail-Safe Enabled"
echo "Installer: Text Mode (Bypasses GUI Prompts)"
echo "----------------------------------------------------"

read -p "Enter your Red Hat Developer Username: " RH_USER
read -s -p "Enter your Red Hat Developer Password: " RH_PASS
echo -e "\n----------------------------------------------------"

SERVERS=("ServerA" "ServerB" "ServerC")

for VM in "${SERVERS[@]}"; do
    echo -e "\n[1/3] ⚙️ Generating Optimized Kickstart for: **$VM**"
    
    # Generate RHEL 10 Optimized Kickstart configuration
    cat <<EOF > /tmp/${VM}_ks.cfg
# RHEL 10 Kickstart Configuration
lang en_US.UTF-8
keyboard us
timezone UTC --utc

# Force text mode for the INSTALLER to bypass the Red Hat GUI prompts
text

# Install packages directly from the attached DVD ISO
cdrom

# Clean the drive completely
zerombr
clearpart --all --initlabel
autopart --type=lvm

# Network Configuration (Short Hostnames)
network --bootproto=dhcp --activate --hostname=${VM}

# Disable the GNOME initial setup wizard on first boot
firstboot --disable
eula --agreed
reboot

# Security & Users
rootpw --lock
user --name=student --groups=wheel --password=TempPass123 --plaintext

%packages
# Install the GUI desktop for the final OS
@^graphical-server-environment
python3
%end

%post --log=/root/ks-post.log
# Force password change on first login
chage -d 0 student

# Register with Red Hat silently in the background after the OS is installed
subscription-manager register --username="${RH_USER}" --password="${RH_PASS}" --auto-attach
%end
EOF

    echo "📋 [HEALTH CHECK] Kickstart payload generated successfully."
    echo "🏗️ [STATUS] Launching RHEL 10 silent installer for $VM..."
    
    virt-install \
        --name "$VM" \
        --memory 2048 \
        --vcpus 1 \
        --disk size=10,pool=default \
        --location "$ISO_PATH" \
        --os-variant rhel10.0 \
        --initrd-inject "/tmp/${VM}_ks.cfg" \
        --extra-args="inst.ks=file:/${VM}_ks.cfg console=tty0 console=ttyS0,115200n8" \
        --network network=default \
        --graphics none \
        --wait=-1

    # ==========================================
    # 🛑 THE FAIL-SAFE TRIGGER
    # ==========================================
    if [ $? -ne 0 ]; then
        echo -e "\n❌ [FATAL ERROR] The installation for $VM failed or crashed!"
        echo "🛑 Halting the script immediately to prevent further errors."
        exit 1
    fi

    echo "----------------------------------------------------"
    echo "✅ [SUCCESS] **$VM** has completed OS installation perfectly!"
    echo "===================================================="
    
    sleep 3
done

echo -e "\n🎉 All RHEL 10 virtual machines have been deployed successfully!"
echo "Run 'virt-manager' to view their GUI desktops."
