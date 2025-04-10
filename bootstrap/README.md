# Bootstrap

_The boostrapping steps required to minimally provision a machine prior to applying forge configuration._

## Setup

We take inspiration from the [NixOS manual installation guide](https://nixos.org/manual/nixos/stable/#sec-installation-manual) with variation introduced to introduce features such as volume encryption. The general setup pattern is to setup a minimal NixOS installation that we then replace with the configuration in this repository.

### Create Bootable USB

The process begins with a bootable USB image of NixOS which can be made by executing the following commands. The [minimal image download can be found here](https://nixos.org/download.html) and the guide on [booting from a USB can be found here](https://nixos.org/manual/nixos/stable/index.html#sec-booting-from-usb).

```bash
dd bs=4M if=nixos-minimal-24.11.716868.60e405b241ed-x86_64-linux.iso of=/dev/sdb
```

### Boot into the Installer

Ensure the following is done in the BIOS before trying to boot from the USB.

- That Secure Boot is disabled.

Then simply set the USB as the bootable device.

### Setup Partitions

Once the system is booted into the minimal image we run the following commands (as root) to setup the disk. The important variation around disk encryption, [setting up LVM on LUKS can be found here](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS).

```bash
gdisk /dev/nvme0n1
# / "p" can be used to print
# o
# n (500M, ef00 EFI)
# n (remaining, 8300 Linux LVM)
# w
partprobe
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 cryptroot
# / "lvmdiskscan" can be used to print
pvcreate /dev/mapper/cryptroot
# / "pvdisplay" can be used to print
# / "pvscan" can be used to print
vgcreate pool /dev/mapper/cryptroot
# / "vgdisplay" can be used to print
lvcreate -l '100%FREE' -n root pool
# / "lvdisplay" can be used to print
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L root /dev/pool/root
```

### Install NixOS

Once we have the disk provisioned, we setup WiFI (if not connected via Ethernet), mount the previously created partitions, and then install NixOS. Details about [installing NixOS can be found here](https://nixos.org/manual/nixos/stable/index.html#sec-installation-installing)

You can setup network access (WiFI) with the following.

```bash
systemctl start wpa_supplicant
wpa_cli
# add_network
# set_network 0 ssid "mynetwork"
# set_network 0 psk "mypassword"
# enable_network 0
# quit
```

And then you can mount and install waith the following.

```bash
mount /dev/disk/by-label/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
# / "lsblk --fs" can be used to print
nixos-generate-config --root /mnt
vim /mnt/etc/nixos/configuration.nix
# ...
#	boot.initrd.luks.devices.luksroot = {
#   device = "/dev/disk/by-uuid/604c3b6b-3c8c-41b7-b3df-576050fb7c1f"; # this is the uuid of /dev/nvme0n1p2
#		preLVM = true;
#		allowDiscards = true;
#	};
nixos-install
reboot
```
