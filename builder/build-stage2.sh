#!/usr/bin/bash
uname -a

pacman-key --init
pacman-key --populate archlinuxarm

# we won't be needing this
pacman -R linux-aarch64 --noconfirm

pacman -Syu switch-boot-files-bin systemd-suspend-modules xorg-server-tegra tegra-bsp switch-configs `cat base-pkgs` --noconfirm #  linux-tegra gcc7 jetson-ffmpeg tegra-ffmpeg --noconfirm
pacman -Rdd ffmpeg --noconfirm

for pkg in `find /pkgs/*.pkg.* -type f`; do
	pacman -U $pkg --noconfirm
done

systemctl enable r2p
systemctl enable bluetooth
systemctl enable lightdm

echo brcmfmac > /etc/suspend-modules.conf
sed -i 's/#keyboard=/keyboard=onboard/' /etc/lightdm/lightdm-gtk-greeter.conf

yes | pacman -Scc

mv /reboot_payload.bin /lib/firmware/
gpasswd -a alarm audio
gpasswd -a alarm video

ldconfig
