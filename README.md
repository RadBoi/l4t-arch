# L4T-Arch

## Docker Build

```sh
./docker-builder/build.sh
```

## Without Docker

### Dependencies

On Arch host install `qemu-user-static` from `AUR` and :

```sh
sudo pacman -S qemu qemu-arch-extra arch-install-scripts parted dosfstools wget libarchive p7zip unzip
```

### Build

On your host :

- Clone this repository `git clone https://github.com/RadBoi/l4t-arch/`
- Run `chmod +x ./l4t-arch/builder/create-rootfs.sh ./l4t-arch/builder/build-stage2.sh && sudo ./l4t-arch/builder/create-rootfs.sh`
