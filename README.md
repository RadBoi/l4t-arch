# L4T-Arch

## Docker

```sh
docker image build -t archl4tbuild:1.0 .
docker run --privileged --cap-add=SYS_ADMIN --rm -i -t --name archl4tbuild archl4tbuild:1.0
```

## Prepare

A SD Card with a minimum of 8Go.

### Dependencies

On Arch host install `qemu-user-static` from `AUR` and :

```sh
sudo pacman -S qemu qemu-arch-extra arch-install-scripts parted dosfstools wget libarchive lvm2 multipath-tools
```

## Build

On your host :

- Switch to root user ( e.g.: `sudo su` )
- Go to l4t-arch/
- Run `./create-rootfs.sh`
- Burn the resulting image from `l4t-arch/l4t-arch.img` to your SD Card
