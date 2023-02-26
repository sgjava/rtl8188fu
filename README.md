This is my fork that I've tested on Armbian builds. It currently works on current and edge releases. ARM32 and ARM64 supported.

For Kernel 4.15.x ~ 6.1.x (Linux Mint, Ubuntu or Debian Derivatives)

------------------

## How to install (for arm devices)

* Armbian to get matching kernel headers
    * `sudo sed -i 's/apt./beta./g' /etc/apt/sources.list.d/armbian.list`
    * `sudo apt update`
    * `sudo apt upgrade`
    * `source /etc/armbian-release`
    * `sudo apt install linux-headers-edge-$LINUXFAMILY`
* Non-Armbian
    * `sudo apt-get install build-essential git dkms linux-headers-$(uname -r)`
* ARM32 
    * `sudo ln -s /lib/modules/$(uname -r)/build/arch/arm /lib/modules/$(uname -r)/build/arch/$(uname -m)`
* ARM64
    * `sudo ln -s /lib/modules/$(uname -r)/build/arch/arm64 /lib/modules/$(uname -r)/build/arch/$(uname -m)`
* `git clone -b arm https://github.com/sgjava/rtl8188fu rtl8188fu-arm`
* `sudo dkms add ./rtl8188fu-arm`
* `sudo dkms build rtl8188fu/1.0`
* `sudo dkms install rtl8188fu/1.0`
* `sudo cp ./rtl8188fu-arm/firmware/rtl8188fufw.bin /lib/firmware/rtlwifi/`
* `sudo reboot`
* `sudo nmtui`

------------------

## Configuration

#### Disable Power Management

Run following commands for disable power management and plugging/replugging issues.

* `sudo mkdir -p /etc/modprobe.d/`
* `sudo touch /etc/modprobe.d/rtl8188fu.conf`
* `echo "options rtl8188fu rtw_power_mgnt=0 rtw_enusbss=0" | sudo tee /etc/modprobe.d/rtl8188fu.conf`

#### Disable MAC Address Spoofing

Run following commands for disabling MAC Address Spoofing (Note: This is not needed on Ubuntu based distributions. MAC Address Spoofing is already disable on Ubuntu base).

* `sudo mkdir -p /etc/NetworkManager/conf.d/`
* `sudo touch /etc/NetworkManager/conf.d/disable-random-mac.conf`
* `echo -e "[device]\nwifi.scan-rand-mac-address=no" | sudo tee /etc/NetworkManager/conf.d/disable-random-mac.conf`

#### Blacklist for kernel 5.15 and newer (No needed for kernel 5.17 and up)

If you are using kernel 5.15 and newer, you must create a configuration file with following commands for preventing to conflict rtl8188fu module with built-in r8188eu module.

`echo 'alias usb:v0BDApF179d*dc*dsc*dp*icFFiscFFipFFin* rtl8188fu' | sudo tee /etc/modprobe.d/r8188eu-blacklist.conf`

------------------

## How to uninstall

* `sudo dkms remove rtl8188fu/1.0 --all`
* `sudo rm -f /lib/firmware/rtlwifi/rtl8188fufw.bin`
* `sudo rm -f /etc/modprobe.d/rtl8188fu.conf`

