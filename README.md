# L4T-Arch

## Docker

```sh
./docker-builder/build.sh
```

## Dependencies

On Arch host install `qemu-user-static` from `AUR` and :

```sh
sudo pacman -S qemu qemu-arch-extra arch-install-scripts parted dosfstools wget libarchive p7zip
```

## Build

On your host :

- Clone this repository
- Log as root user ( `sudo su` )
- Run `./l4t-arch/builder/create-rootfs.sh`