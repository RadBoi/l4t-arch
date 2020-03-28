# L4T-Arch

## Required

You'll need `wget`, `bsdtar`and `kpartx` to build the script :

```sh
pacman -S libarchive wget multipath-tools ## On Arch host
```

## Build

- Switch to root user ( e.g.: `sudo su` )
- Go to l4t-arch/builder/
- Run `./create-rootfs.sh`
- Burn the resulting image from `l4t-arch/builder/build/l4t-arch.img.gz` to your SD Card
- Connect it to internet by ethernet
- SSH to your switch (user: alarm / password : alarm)
- Run `bash /build-stage2.sh` on your switch
