#!/usr/bin/bash
uname -a

pacman-key --init
pacman-key --populate archlinuxarm

# we won't be needing this
pacman -R linux-aarch64 --noconfirm

pacman -Syu `cat base-pkgs` --noconfirm # TODO: add {linux-tegra gcc7 jetson-ffmpeg tegra-ffmpeg}
pacman -Rdd ffmpeg --noconfirm

for pkg in `find /pkgs/*.pkg.* -type f`; do
	pacman -U $pkg --noconfirm
done

systemctl enable r2p
systemctl enable bluetooth
systemctl enable sddm
systemctl enable NetworkManager

echo brcmfmac > /etc/suspend-modules.conf
sed -i 's/\[General\]/&\nInputMethod=qtvirtualkeyboard/g' /etc/sddm.conf
echo "export QT_IM_MODULE=qtvirtualkeyboard" >> /etc/profile.d/qt5-virtualkeyboard.sh

yes | pacman -Scc

mv /reboot_payload.bin /lib/firmware/
gpasswd -a alarm audio
gpasswd -a alarm video

ldconfig
