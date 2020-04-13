# L4T-Arch

## Docker

```sh
docker image build -t archl4tbuild:1.0 .
docker run --privileged --cap-add=SYS_ADMIN --rm -i -t --name archl4tbuild archl4tbuild:1.0
```

## Dependencies

On Arch host install `qemu-user-static` from `AUR` and :

```sh
sudo pacman -S qemu qemu-arch-extra arch-install-scripts parted dosfstools wget libarchive lvm2 multipath-tools
```

## Build

On your host :

- Clone this repository
- Log as root user ( `sudo su` )
- Run `./l4t-arch/builder/create-rootfs.sh`