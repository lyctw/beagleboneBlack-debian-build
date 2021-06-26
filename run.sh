#!/bin/bash

./download_toolchain.sh

./build_uboot.sh
./prepare_SDCard.sh
./build_linux.sh
