#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

## TODO: size should be defined dynamically
size=6G

cleanup(){
	umount tmp/mnt/boot/
	umount tmp/mnt/root/
	kpartx -d build/l4t-arch.img
	rm -r tmp/
}

setup_base(){
	
	mkdir -p tmp/
	mkdir -p tmp/arch-bootfs/
	mkdir -p tmp/arch-rootfs/

	### Bootfs Setup
	
	
	###  Rootfs Setup
	mkdir -p tarballs

	if [[ ! -e tarballs/ArchLinuxARM-aarch64-latest.tar.gz ]]; then
		wget -O tarballs/ArchLinuxARM-aarch64-latest.tar.gz http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
	fi

	if [[ ! -e reboot_payload.bin ]]; then
		wget https://github.com/CTCaer/hekate/releases/download/v5.1.3/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
		unzip hekate_ctcaer_5.1.3_Nyx_0.8.6.zip hekate_ctcaer_5.1.3.bin
		mv hekate_ctcaer_5.1.3.bin tmp/arch-rootfs/reboot_payload.bin
		rm hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
	fi

	cp pkgs/build-stage2.sh pkgs/base-pkgs pkgs/optional-pkgs tmp/arch-rootfs/

	bsdtar xpf tarballs/ArchLinuxARM-aarch64-latest.tar.gz -C tmp/arch-rootfs/

	cat << EOF >> tmp/arch-rootfs/etc/pacman.conf
	[switch]
	SigLevel = Optional
	Server = https://9net.org/l4t-arch/
EOF
}

make_iso(){

	mkdir -p build/
	mkdir -p tmp/mnt/boot/
	mkdir -p tmp/mnt/root/

	dd if=/dev/zero of=build/l4t-arch.img bs=1 count=0 seek=$size

	## TODO: Format partitions
	
	## This doesn't work properly
	# (echo n; echo p; echo 1; echo 1; echo 476; echo n; echo p; echo 2; echo ; echo ; echo w) | fdisk build/l4t-arch.img

	## TODO: Script shouldn't assume loop is loop0
	kpartx -a build/l4t-arch.img

	mkfs.fat -F 32 /dev/mapper/loop0p1
	mkfs.ext4 /dev/mapper/loop0p2

	mount -o loop /dev/mapper/loop0p1 tmp/mnt/boot/
	mount -o loop /dev/mapper/loop0p2 tmp/mnt/root/
	
	cp -pr tmp/arch-bootfs/* tmp/mnt/boot/
	cp -pr tmp/arch-rootfs/* tmp/mnt/root/

	umount tmp/mnt/boot/
	umount tmp/mnt/root/

	kpartx -d build/l4t-arch.img

	rm -rf tmp/

	gzip build/l4t-arch.img
}


if [[ `whoami` != root ]]; then
	echo hey! run this as root.
	exit
fi

cleanup
setup_base
make_iso

echo "Done!\n"
