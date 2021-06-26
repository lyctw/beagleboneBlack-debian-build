#!/bin/bash
set -x

source ./env
if [ ! -d $WORKSPACE/u-boot ]; then
  git clone -b v2019.04 https://github.com/u-boot/u-boot --depth=1
fi
cd u-boot
make distclean
make am335x_evm_defconfig
make -j $(nproc) 
