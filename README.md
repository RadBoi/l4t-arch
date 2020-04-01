# L4T-Arch

## Required

- Min. 8Go Micro SDCard
You'll need `parted`, `dosfstools`,`wget`, `bsdtar`and `kpartx` to build the script.

## Build

On your host :

- Switch to root user ( e.g.: `sudo su` )
- Go to l4t-arch/
- Run `./create-rootfs.sh`
- `cd /pkgbuilds` and in `nvidia-drivers-package` `jetson-ffmpeg` and `ffmpeg` directories (respecting this order) do `makepkg -si`
- Burn the resulting image from `l4t-arch/l4t-arch.img` to your SD Card
