# L4T-Arch

## Required

- Min. 8Go Micro SDCard

You'll need `wget`, `bsdtar`and `kpartx` to build the script :

```sh
pacman -S libarchive wget multipath-tools ## On Arch host
```

## Build

On your host :

- Switch to root user ( e.g.: `sudo su` )
- Go to l4t-arch/builder/
- Run `./create-rootfs.sh`
- Burn the resulting image from `l4t-arch/build/l4t-arch.img` to your SD Card

On your switch :

- Connect your switch via ethernet and SSH in it (user: alarm / password : alarm) from your host (or hook a kb and screen to your dock)
- `su` to log as root (password : root)
- Run `bash /build-stage2.sh`
- If some packages failed to install try again
- `exit` root
- `cd /pkgbuilds` and in `nvidia-drivers-package` `jetson-ffmpeg` and `ffmpeg` directories (respecting this order) do `makepkg -si`
