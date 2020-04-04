#!/usr/bin/bash
uname -a

# arch-chroot doesn't do this for us, so let's do it ourselves.
mkdir /mnt/hos_data/l4t-arch -p
mount --bind /mnt/hos_data/l4t-arch/ /boot/

pacman-key --init
pacman-key --populate archlinuxarm

# we won't be needing this
pacman -R linux-aarch64 --noconfirm

until pacman -Syu switch-boot-files-bin systemd-suspend-modules xorg-server-tegra switch-configs linux-tegra gcc7 `cat base-pkgs` --noconfirm
# until pacman -Syu switch-boot-files-bin systemd-suspend-modules xorg-server-tegra switch-configs tegra-bsp linux-tegra gcc7 `cat base-pkgs` --noconfirm
do
	echo "Error check your build or let the script retry last cmd"
done

cd /pkgbuils/nvidia-drivers-package/ && pacman -U tegra-bsp-r32-3.1-any.pkg.tar.xz && cd /

systemctl enable r2p
systemctl enable bluetooth
systemctl enable lightdm
sed -i 's/#keyboard=/keyboard=onboard/' /etc/lightdm/lightdm-gtk-greeter.conf

yes | pacman -Scc

mv /reboot_payload.bin /lib/firmware/
gpasswd -a alarm audio
gpasswd -a alarm video


umount /boot

cd /mnt/hos_data/
tar cz * > /arch-boot.tar.gz
cd /

rm -r /boot/*
rm -r /mnt/hos_data/*
mkdir -p /mnt/hos_data