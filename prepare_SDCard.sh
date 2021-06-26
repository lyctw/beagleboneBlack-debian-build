#!/bin/bash
set -x

source ./env
# Create boot partition and install u-boot
export DISK=$1
# Comfirm SD card device id
while true; do
  read -p "Make sure your SD card is $DISK !!" yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
done
sudo dd if=/dev/zero of=${DISK} bs=1M count=10
sudo dd if=$WORKSPACE/u-boot/MLO of=${DISK} count=1 seek=1 bs=128k
sudo dd if=$WORKSPACE/u-boot/u-boot.img of=${DISK} count=2 seek=1 bs=384k
# Create rootfs partition and format it
sudo sfdisk ${DISK} <<-__EOF__
4M,,L,*
__EOF__
sudo mkfs.ext4 -L rootfs -O ^64bit ${DISK}1
# Mount rootfs
mkdir -p  $WORKSPACE/rootfs
sudo mount ${DISK}1 $WORKSPACE/rootfs
# Backup U-boot
sudo mkdir -p $WORKSPACE/rootfs/opt/backup/uboot/
sudo cp -v $WORKSPACE/u-boot/MLO $WORKSPACE/rootfs/opt/backup/uboot/
sudo cp -v $WORKSPACE/u-boot/u-boot.img $WORKSPACE/rootfs/opt/backup/uboot/
# Download debian rootfs
wget -c https://rcn-ee.com/rootfs/eewiki/minfs/debian-10.4-minimal-armhf-2020-05-10.tar.xz
if [ ! -d $WORKSPACE/debian-10.4-minimal-armhf-2020-05-10/ ]; then
  tar xf $WORKSPACE/debian-10.4-minimal-armhf-2020-05-10.tar.xz
fi
# Install rootfs
sudo tar xfvp $WORKSPACE/debian-10.4-minimal-armhf-2020-05-10/armhf-rootfs-debian-buster.tar -C $WORKSPACE/rootfs
sync
sudo chown root:root $WORKSPACE/rootfs/
sudo chmod 755 $WORKSPACE/rootfs/

# 
ll -h $WORKSPACE/rootfs
sync
sleep 2
echo "Prepare debian rootfs done. Then run ./build_linux"
