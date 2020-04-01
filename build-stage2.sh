#!/usr/bin/bash
uname -a

pacman-key --init
pacman-key --populate archlinuxarm

until pacman -Syu xorg-server-tegra switch-configs  `cat base-pkgs` --noconfirm
#until pacman -Syu xorg-server-tegra switch-configs nvidia-drivers-package l4t-switch-kernel `cat base-pkgs` --noconfirm
do
	echo "Error check your build or let the script retry last cmd"
done

systemctl enable r2p
systemctl enable bluetooth
systemctl enable lightdm
sed -i 's/#keyboard=/keyboard=onboard/' /etc/lightdm/lightdm-gtk-greeter.conf

yes | pacman -Scc

mv /reboot_payload.bin /lib/firmware/
gpasswd -a alarm audio
gpasswd -a alarm video
