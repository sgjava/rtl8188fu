#!/bin/sh
#
# Created on February 26, 2023
#
# @author: sgoldsmith
#
# Install RTL8188FU driver on Armbian.
#
# This assumes you cloned into home dir.
#
# Steven P. Goldsmith
# sgjava@gmail.com
#

# Get architecture
arch=$(uname -m)

# stdout and stderr for commands logged
logfile="$PWD/install.log"
rm -f $logfile

# Simple logger
log(){
	timestamp=$(date +"%m-%d-%Y %k:%M:%S")
	echo "$timestamp $1"
	echo "$timestamp $1" >> $logfile 2>&1
}

# Remove old version
log "Removing existing driver"
sudo -E dkms remove rtl8188fu/1.0 --all >> $logfile 2>&1
sudo -E rm -f /lib/firmware/rtlwifi/rtl8188fufw.bin >> $logfile 2>&1
sudo -E rm -f /etc/modprobe.d/rtl8188fu.conf >> $logfile 2>&1
log "Remove modules link"
 sudo -E rm /lib/modules/$(uname -r)/build/arch/"$arch" >> $logfile 2>&1

# Set Armbian to beta repos
log "Switch to Armbian beta repos"
sudo -E sed -i 's/apt./beta./g' /etc/apt/sources.list.d/armbian.list >> $logfile 2>&1
sudo -E apt update >> $logfile 2>&1
yes N | dpkg --configure -a
sudo apt  -y upgrade  >> $logfile 2>&1
. /etc/armbian-release >> $logfile 2>&1
sudo -E apt -y  install linux-headers-edge-$LINUXFAMILY >> $logfile 2>&1

log "Create modules link"
# ARM 32
if [ "$arch" = "armv7l" ]; then
    sudo -E ln -s /lib/modules/$(uname -r)/build/arch/arm /lib/modules/$(uname -r)/build/arch/"$arch" >> $logfile 2>&1
# ARM 64
elif [ "$arch" = "aarch64" ]; then
	sudo -E ln -s /lib/modules/$(uname -r)/build/arch/arm64 /lib/modules/$(uname -r)/build/arch/"$arch" >> $logfile 2>&1
# X86_32
elif [ "$arch" = "i586" ] || [ "$arch" = "i686" ]; then
	sudo -E ln -s /lib/modules/$(uname -r)/build/arch/x86 /lib/modules/$(uname -r)/build/arch/"$arch" >> $logfile 2>&1
# X86_64	
elif [ "$arch" = "x86_64" ]; then
    sudo -E ln -s /lib/modules/$(uname -r)/build/arch/x86_64 /lib/modules/$(uname -r)/build/arch/"$arch" >> $logfile 2>&1
fi

# Build project
log "Building"
sudo -E dkms add ./rtl8188fu-arm >> $logfile 2>&1
sudo -E dkms build rtl8188fu/1.0 >> $logfile 2>&1
sudo -E dkms install rtl8188fu/1.0 >> $logfile 2>&1
sudo -E cp ./rtl8188fu-arm/firmware/rtl8188fufw.bin /lib/firmware/rtlwifi/ >> $logfile 2>&1

log "Build complete, check log $logfile, reboot and use sudo nmtui to configure"

