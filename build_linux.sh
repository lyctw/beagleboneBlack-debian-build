#!/bin/bash
set -x

source ./env
# Download kernel
if [ ! -d $WORKSPACE/linux ]; then
  git clone -b v5.12 https://github.com/torvalds/linux
fi
cd $WORKSPACE/linux
# Configure kernel
make multi_v7_defconfig
# Compile kernel
make -j $(nproc) zImage
# Compile device tree
make dtbs
# Compile kernel modules
makn -j $(nproc) modules
# Get kernel verision and add to uEnv.txt
kernel_version=$(make kernelversion)
sudo sh -c "echo 'uname_r=${kernel_version}' >> $WORKSPACE/rootfs/boot/uEnv.txt"
# Install kernel image, device tree and kernel modules
sudo cp -v $WORKSPACE/linux/arch/arm/boot/zImage $WORKSPACE/rootfs/boot/vmlinuz-${kernel_version}
sudo mkdir -p $WORKSPACE/rootfs/boot/dtbs/${kernel_version}
sudo cp -v $WORKSPACE/linux/arch/arm/boot/dts/*.dtb $WORKSPACE/rootfs/boot/dtbs/${kernel_version}
sudo make -j $(nproc) INSTALL_MOD_PATH=$WORKSPACE/rootfs modules_install

# Set rootfs table
sudo sh -c "echo '/dev/mmcblk0p1  /  auto  errors=remount-ro  0  1' >> $WORKSPACE/rootfs/etc/fstab"

# Set network 
sudo sh -c "echo 'auto lo               ' >> $WORKSPACE/rootfs/etc/network/interfaces"
sudo sh -c "echo 'iface lo inet loopback' >> $WORKSPACE/rootfs/etc/network/interfaces"
sudo sh -c "echo '                      ' >> $WORKSPACE/rootfs/etc/network/interfaces"
sudo sh -c "echo 'auto eth0             ' >> $WORKSPACE/rootfs/etc/network/interfaces"
sudo sh -c "echo 'iface eth0 inet dhcp  ' >> $WORKSPACE/rootfs/etc/network/interfaces"

# Flushes all pending write operations
sync

# Unmount rootfs, done.
ls $WORKSPACE/rootfs
sleep 2
sudo umount $WORKSPACE/rootfs
