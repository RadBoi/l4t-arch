#!/usr/bin/bash
uname -a

pacman-key --init
pacman-key --populate archlinuxarm

# we won't be needing this
pacman -R linux-aarch64 --noconfirm

until pacman -Syu systemd-suspend-modules xorg-server-tegra switch-configs `cat base-pkgs` --noconfirm
# until pacman -Syu switch-boot-files-bin systemd-suspend-modules xorg-server-tegra switch-configs tegra-bsp linux-tegra gcc7 `cat base-pkgs` --noconfirm
do
	echo "Error check your build or let the script retry last cmd"
done

pacman -U /pkgs/tegra-bsp-r32-3.1-any.pkg.tar.xz /pkgs/switch-boot-files-bin-r32-1-any.pkg.tar.xz --noconfirm

systemctl enable r2p
systemctl enable bluetooth
systemctl enable lightdm
sed -i 's/#keyboard=/keyboard=onboard/' /etc/lightdm/lightdm-gtk-greeter.conf

yes | pacman -Scc

mv /reboot_payload.bin /lib/firmware/
gpasswd -a alarm audio
gpasswd -a alarm video

ldconfig
