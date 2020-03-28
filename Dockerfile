FROM archlinux:latest
USER root
RUN pacman -Syu base base-devel dhcpcd iproute2 git wget unzip libarchive multipath-tools --noconfirm
COPY . /root
RUN cd /root/l4t-arch/ && ./create-rootfs.sh