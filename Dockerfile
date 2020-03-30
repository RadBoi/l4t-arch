FROM archlinux:latest
USER root
RUN pacman -Syu base base-devel dhcpcd iproute2 git wget unzip libarchive multipath-tools --noconfirm
ADD create-rootfs.sh /root
ADD pkgs /root/pkgs
ADD rootfs /root/rootfs
ADD bootfs /root/bootfs
ADD tarballs /root/tarballs
RUN cd /root && ./create-rootfs.sh