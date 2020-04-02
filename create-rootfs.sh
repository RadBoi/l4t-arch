#!/bin/bash
## TODO: size should be defined dynamically
size=6G

cleanup(){
	umount tmp/mnt/boot/
	umount tmp/mnt/root/
	kpartx -d l4t-arch.img
	umount -R tmp/arch-rootfs/
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

	if [[ ! -e tmp/arch-rootfs/reboot_payload.bin ]]; then
		wget -O tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip https://github.com/CTCaer/hekate/releases/download/v5.1.3/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
		unzip tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip hekate_ctcaer_5.1.3.bin
		mv hekate_ctcaer_5.1.3.bin tmp/arch-rootfs/reboot_payload.bin
		rm tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
	fi
}

## TODO: Up to date kernel should be online
setup_boot(){
	cp -r kernel/bootfs/* tmp/arch-bootfs/
	cp -pr kernel/rootfs/lib/ tmp/arch-bootfs/usr/
}

setup_base(){
	cp build-stage2.sh base-pkgs tmp/arch-rootfs/
	cp -r pkgbuilds/ tmp/arch-rootfs/
	
	bsdtar xpf tarballs/ArchLinuxARM-aarch64-latest.tar.gz -C tmp/arch-rootfs/

	cat << EOF >> tmp/arch-rootfs/etc/pacman.conf
	[switch]
	SigLevel = Optional
	Server = https://9net.org/l4t-arch/
EOF

	echo -e "/dev/mmcblk0p1	/mnt/hos_data	vfat	rw,relatime	0	2\n/boot /mnt/hos_data/l4t-arch/	none	bind	0	0" >> tmp/arch-rootfs/etc/fstab

	cp /usr/bin/qemu-aarch64-static tmp/arch-rootfs/usr/bin/
	cp /etc/resolv.conf tmp/arch-rootfs/etc/
	
	mount --bind tmp/arch-rootfs tmp/arch-rootfs

	arch-chroot tmp/arch-rootfs/ ./build-stage2.sh
	
	umount -R tmp/arch-rootfs/
}

buildiso(){
	mkdir -p tmp/mnt/boot/
	mkdir -p tmp/mnt/root/

	dd if=/dev/zero of=l4t-arch.img bs=1 count=0 seek=$size
	
	parted l4t-arch.img --script -- mklabel msdos
	parted -a optimal l4t-arch.img mkpart primary 0% 476MB
	parted -a optimal l4t-arch.img mkpart primary 477MB 100%

	loop_dev=$(kpartx -av l4t-arch.img | grep -oh "\w*loop\w*")

	loop1=`echo "${loop_dev}" | head -1`
	loop2=`echo "${loop_dev}" | tail -1`

	mkfs.fat -F 32 /dev/mapper/${loop1}
	mkfs.ext4 /dev/mapper/${loop2}

	mount -o loop /dev/mapper/${loop1} tmp/mnt/boot/
	mount -o loop /dev/mapper/${loop2} tmp/mnt/root/
	
	cp -r tmp/arch-bootfs/* tmp/mnt/boot/
	cp -pr tmp/arch-rootfs/* tmp/mnt/root/
}

if [[ `whoami` != root ]]; then
	echo hey! run this as root.
	exit
fi

cleanup
prepare
setup_base
setup_boot
buildiso
cleanup

echo "Done!\n"
