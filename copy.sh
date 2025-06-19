#!/bin/bash
set -xe
IMAGE=/media/arendjan/armbi_root
if [ ! -d "$IMAGE" ]; then
  echo "Directory $IMAGE does not exist."
  exit 1
fi
sudo cp $IMAGE/boot/Image /srv/tftp/zero2Image
sudo rm -rf /mirte/mirte-test/nfsroot || true
sudo mkdir -p /mirte/mirte-test/nfsroot
sudo cp -rp $IMAGE/. /mirte/mirte-test/nfsroot
sudo cp $IMAGE/boot/dtb/allwinner/sun50i-h616-orangepi-zero2.dtb /srv/tftp/            
ls /mirte/mirte-test/nfsroot/