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

	rm -rf tmp/
}

prepare() {
	mkdir -p tmp/
	mkdir -p tmp/arch-bootfs/
	mkdir -p tmp/arch-rootfs/
	mkdir -p tarballs/

	if [[ ! -e tarballs/ArchLinuxARM-aarch64-latest.tar.gz ]]; then
		wget -O tarballs/ArchLinuxARM-aarch64-latest.tar.gz http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
	fi

	if [[ ! -e reboot_payload.bin ]]; then
		wget https://github.com/CTCaer/hekate/releases/download/v5.1.3/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
		unzip hekate_ctcaer_5.1.3_Nyx_0.8.6.zip hekate_ctcaer_5.1.3.bin
		mv hekate_ctcaer_5.1.3.bin tmp/arch-rootfs/reboot_payload.bin
		rm hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
	fi
}

## TODO: Up to date kernel should be online
setup_boot(){
	cp -pr bootfs/* tmp/arch-bootfs/
	cp -pr rootfs/lib/ tmp/arch-bootfs/usr/
}

setup_base(){
	cp pkgs/build-stage2.sh pkgs/base-pkgs pkgs/optional-pkgs tmp/arch-rootfs/

	bsdtar xpf tarballs/ArchLinuxARM-aarch64-latest.tar.gz -C tmp/arch-rootfs/

	cat << EOF >> tmp/arch-rootfs/etc/pacman.conf
	[switch]
	SigLevel = Optional
	Server = https://9net.org/l4t-arch/
EOF

	setup_boot
}

buildiso(){
	mkdir -p build/
	mkdir -p tmp/mnt/boot/
	mkdir -p tmp/mnt/root/

	dd if=/dev/zero of=build/l4t-arch.img bs=1 count=0 seek=$size

	parted -a optimal build/l4t-arch.img mkpart primary 0% 476MB
	parted -a optimal build/l4t-arch.img mkpart primary 477MB 100%

	loop_dev=$(kpartx -av build/l4t-arch.img | grep -oh "\w*loop\w*")

	loop1=$(sed -n '1d' ${loop_dev})
	loop2=$(sed -n '2d' ${loop_dev})

	mkfs.fat -F 32 /dev/mapper/${loop1}
	mkfs.ext4 /dev/mapper/${loop2}

	mount -o loop /dev/mapper/${loop1} tmp/mnt/boot/
	mount -o loop /dev/mapper/${loop2} tmp/mnt/root/
	
	cp -pr tmp/arch-bootfs/* tmp/mnt/boot/
	cp -pr tmp/arch-rootfs/* tmp/mnt/root/
	
	cleanup

	gzip build/l4t-arch.img
}

if [[ `whoami` != root ]]; then
	echo hey! run this as root.
	exit
fi

cleanup
prepare
setup_base
buildiso

echo "Done!\n"
