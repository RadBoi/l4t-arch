#!/bin/bash

root_dir="$(dirname "$(dirname "$(readlink -fm "$0")")")"

cleanup(){
	umount -R ${root_dir}/tmp/mnt/*
	umount -R ${root_dir}/tmp/*
	kpartx -d ${root_dir}/l4t-arch.img
	rm -rf ${root_dir}/tmp/
}

prepare() {
	mkdir -p ${root_dir}/tarballs/
	mkdir -p ${root_dir}/tmp/arch-bootfs/
	mkdir -p ${root_dir}/tmp/arch-rootfs/
	mkdir -p ${root_dir}/tmp/mnt/bootfs/
	mkdir -p ${root_dir}/tmp/mnt/rootfs/

	if [[ ! -e ${root_dir}/tarballs/ArchLinuxARM-aarch64-latest.tar.gz ]]; then
		wget -O ${root_dir}/tarballs/ArchLinuxARM-aarch64-latest.tar.gz http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
	fi

	if [[ ! -e ${root_dir}/tmp/arch-rootfs/reboot_payload.bin ]]; then
		wget https://github.com/CTCaer/hekate/releases/download/v5.1.3/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip -P ${root_dir}/tmp/
		unzip ${root_dir}/tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip hekate_ctcaer_5.1.3.bin
		mv hekate_ctcaer_5.1.3.bin ${root_dir}/tmp/arch-rootfs/reboot_payload.bin
		rm ${root_dir}/tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
	fi
}

setup_bootfs(){
	cp -r ${root_dir}/kernel/bootfs/* ${root_dir}/tmp/arch-bootfs/
	cp -pdr ${root_dir}/kernel/rootfs/lib/modules/* ${root_dir}/tmp/arch-rootfs/usr/lib/modules
}

setup_rootfs(){
	cp build-stage2.sh base-pkgs ${root_dir}/tmp/arch-rootfs/
	cp -r ${root_dir}/pkgbuilds/ ${root_dir}/tmp/arch-rootfs/
	
	bsdtar xpf ${root_dir}/tarballs/ArchLinuxARM-aarch64-latest.tar.gz -C ${root_dir}/tmp/arch-rootfs/

	echo "[switch]
	SigLevel = Optional
	Server = https://9net.org/l4t-arch/
	[switch-preview]
	SigLevel = Optional
	Server = https://9net.org/~stary/preview-pkgs/" >> ${root_dir}/tmp/arch-rootfs/etc/pacman.conf

	echo -e "/dev/mmcblk0p1	/mnt/hos_data	vfat	rw,relatime	0	2\n/boot /mnt/hos_data/l4t-arch/	none	bind	0	0" >> ${root_dir}/tmp/arch-rootfs/etc/fstab

	cp /usr/bin/qemu-aarch64-static ${root_dir}/tmp/arch-rootfs/usr/bin/
	cp /etc/resolv.conf ${root_dir}/tmp/arch-rootfs/etc/
	
	mount --bind ${root_dir}/tmp/arch-rootfs ${root_dir}/tmp/arch-rootfs
	arch-chroot ${root_dir}/tmp/arch-rootfs/ ./build-stage2.sh
	umount -R ${root_dir}/tmp/arch-rootfs/

	rm ${root_dir}/tmp/fedora-rootfs/etc/pacman.d/gnupg/S.gpg-agent*
	rm -rf ${root_dir}/tmp/arch-rootfs/{pkgbuilds,build-stage2.sh}
	rm ${root_dir}/tmp/arch-rootfs/usr/bin/qemu-aarch64-static
}

buildiso(){
	size=$(du -hs ${root_dir}/tmp/arch-rootfs/ | head -n1 | awk '{print int($1+2);}')$(du -hs ${root_dir}/tmp/arch-rootfs/ | head -n1 | awk '{print $1;}' | grep -o '[[:alpha:]]')

	dd if=/dev/zero of=${root_dir}/l4t-arch.img bs=1 count=0 seek=$size
	
	parted ${root_dir}/l4t-arch.img --script -- mklabel msdos
	parted -a optimal ${root_dir}/l4t-arch.img mkpart primary 0% 476MB
	parted -a optimal ${root_dir}/l4t-arch.img mkpart primary 477MB 100%
	
	loop_dev=$(kpartx -av ${root_dir}/l4t-arch.img | grep -oh "\w*loop\w*")

	loop1=`echo "${loop_dev}" | head -1`
	loop2=`echo "${loop_dev}" | tail -1`

	mkfs.fat -F 32 /dev/mapper/${loop1}
	mkfs.ext4 /dev/mapper/${loop2}

	mount -o loop /dev/mapper/${loop1} ${root_dir}/tmp/mnt/bootfs/
	mount -o loop /dev/mapper/${loop2} ${root_dir}/tmp/mnt/rootfs/
	
	cp -r ${root_dir}/tmp/arch-bootfs/* ${root_dir}/tmp/mnt/bootfs/
	cp -pdr ${root_dir}/tmp/arch-rootfs/* ${root_dir}/tmp/mnt/rootfs/
}

if [[ `whoami` != root ]]; then
	echo hey! run this as root.
	exit
fi

cleanup
prepare
setup_rootfs
setup_bootfs
buildiso
cleanup

echo "Done!\n"
