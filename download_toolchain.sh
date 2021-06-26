#!/bin/bash

if [ -f $(pwd)/armv7-eabihf--glibc--bleeding-edge-2020.08-1.tar.bz2 ]; then
  exit 0
fi
wget https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--glibc--bleeding-edge-2020.08-1.tar.bz2
tar xvf armv7-eabihf--glibc--bleeding-edge-2020.08-1.tar.bz2
