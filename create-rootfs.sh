#!/bin/bash

cleanup(){
	umount -R tmp/mnt/*
	umount -R tmp/*
	kpartx -d l4t-arch.img
	rm -rf tmp/
}

prepare() {
	mkdir -p tarballs/
	mkdir -p tmp/arch-bootfs/
	mkdir -p tmp/arch-rootfs/
	mkdir -p tmp/mnt/bootfs/
	mkdir -p tmp/mnt/rootfs/

	if [[ ! -e tarballs/ArchLinuxARM-aarch64-latest.tar.gz ]]; then
		wget -O tarballs/ArchLinuxARM-aarch64-latest.tar.gz http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
	fi

	if [[ ! -e tmp/arch-rootfs/reboot_payload.bin ]]; then
		wget https://github.com/CTCaer/hekate/releases/download/v5.1.3/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip -P tmp/
		unzip tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip hekate_ctcaer_5.1.3.bin
		mv hekate_ctcaer_5.1.3.bin tmp/arch-rootfs/reboot_payload.bin
		rm tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
	fi
}

## TODO: Up to date kernel should be online
setup_bootfs(){
	cp -r kernel/bootfs/* tmp/arch-bootfs/
	# cp -pdr kernel/rootfs/lib/ tmp/arch-rootfs/usr/
}

setup_rootfs(){
	cp build-stage2.sh base-pkgs tmp/arch-rootfs/
	cp -r pkgbuilds/ tmp/arch-rootfs/
	
	bsdtar xpf tarballs/ArchLinuxARM-aarch64-latest.tar.gz -C tmp/arch-rootfs/

	cat << EOF >> tmp/arch-rootfs/etc/pacman.conf
	[switch]
	SigLevel = Optional
	Server = https://9net.org/l4t-arch/
	[switch-preview]
	SigLevel = Optional
	Server = https://9net.org/~stary/preview-pkgs/
EOF

	echo -e "/dev/mmcblk0p1	/mnt/hos_data	vfat	rw,relatime	0	2\n/boot /mnt/hos_data/l4t-arch/	none	bind	0	0" >> tmp/arch-rootfs/etc/fstab

	cp /usr/bin/qemu-aarch64-static tmp/arch-rootfs/usr/bin/
	cp /etc/resolv.conf tmp/arch-rootfs/etc/
	
	mount --bind tmp/arch-rootfs tmp/arch-rootfs
	arch-chroot tmp/arch-rootfs/ ./build-stage2.sh
	umount -R tmp/arch-rootfs/

	rm tmp/fedora-rootfs/etc/pacman.d/gnupg/S.gpg-agent*
	rm -rf tmp/arch-rootfs/{pkgbuilds,build-stage2.sh}
	rm tmp/arch-rootfs/usr/bin/qemu-aarch64-static
}

buildiso(){
	size=$(du -hs tmp/arch-rootfs/ | head -n1 | awk '{print int($1+2);}')$(du -hs tmp/arch-rootfs/ | head -n1 | awk '{print $1;}' | grep -o '[[:alpha:]]')

	dd if=/dev/zero of=l4t-arch.img bs=1 count=0 seek=$size
	
	parted l4t-arch.img --script -- mklabel msdos
	parted -a optimal l4t-arch.img mkpart primary 0% 476MB
	parted -a optimal l4t-arch.img mkpart primary 477MB 100%
	
	loop_dev=$(kpartx -av l4t-arch.img | grep -oh "\w*loop\w*")

	loop1=`echo "${loop_dev}" | head -1`
	loop2=`echo "${loop_dev}" | tail -1`

	mkfs.fat -F 32 /dev/mapper/${loop1}
	mkfs.ext4 /dev/mapper/${loop2}

	mount -o loop /dev/mapper/${loop1} tmp/mnt/bootfs/
	mount -o loop /dev/mapper/${loop2} tmp/mnt/rootfs/
	
	cp -r tmp/arch-bootfs/* tmp/mnt/bootfs/
	cp -pdr tmp/arch-rootfs/* tmp/mnt/rootfs/
}

if [[ `whoami` != root ]]; then
	echo hey! run this as root.
	exit
fi

cleanup
prepare
setup_bootfs
setup_rootfs
buildiso
cleanup

echo "Done!\n"
