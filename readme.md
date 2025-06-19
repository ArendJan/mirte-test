# NFS boot armbian

## Main machine setup
- install tftp
- install nfs server
  - create nfs root folder (/mirte/mirte-test/nfsroot from now): sudo mkdir -p /mirte/mirte-test/nfsroot
  - add nfs root to /etc/exports(single line):
    - ```/mirte/mirte-test/nfsroot/ 10.42.0.133(rw,no_root_squash,no_subtree_check)```
    - $folder $ip_of_board (some settings)


- ./compile boot-config => change boot command to
```
run distro_bootcmd; env set bootargs ${bootargs} root=/dev/nfs ip=10.42.0.133:::::eth0 nfsroot=10.42.0.1:/mirte/mirte-test/nfsroot,nfsvers=3,tcp rw nfsrootdebug; env set bootcmd 'tftp 0x40080000 zero2Image; tftp 0x43000000 sun50i-h616-orangepi-zero2.dtb; booti 0x40080000 - 0x43000000'; boot
```
- what it sets:
   - distro_bootcmd is the original
   - bootargs: add nfs with some ip  and where to find the root (ip and folder)
   - tftp $image_name (zero2Image): where to find the kernel image (in /srv/tftp folder)
   - tftp dtb: also get the dtb
   - boot!
 - ./compile kernel-config, change:
   - root_nfs = y
   - nfs_v3 = y
   - ethernet driver (to figure it out: ```ls -1 /sys/class/net/ | grep -v lo | xargs -n1 -I{} bash -c 'echo -n {} :" " ; basename `readlink -f /sys/class/net/{}/device/driver`'```)
     - stmmac with CONFIG_DWMAC_SUNXI or CONFIG_DWMAC_SUN8I for zero2
   - (copy the patch file?)
 - compile for your board
 - flash to sd card
 - test the sd card that the kernel and everything works with your special image
   - check/change settings to have your main machine has ethernet sharing on and that it gets the ip used previously (10.42.0.1)
 - delete the armbi_root partition from the sd, this will make it seem that it's empty, but the bootloader will still be there.
 - mount the .img file
 - copy the /boot/Image to /srv/tftp/$image_name
 - copy the /boot/dtb/<manufacturer(allwinner/rockchip)>/$chip-board-name.dtb to /srv/tftp/ (sun50i-h616-orangepi-zero2.dtb for zero2)
 - copy the complete image to the folder that you set as nfs root (needs to be read-writable). Use cp -rp to preserve permissions, otherwise it will not boot correctly.
 - give the board power! It should download the image file after trying the other possible hardware storages (unable to as there is no partition anymore), then download the dtb (device tree) and boot the kernel with the nfs parameters, and the image will boot normally.