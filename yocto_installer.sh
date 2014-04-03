#!/bin/bash

rm -rf ~/YS
mkdir ~/YS
wget -O ~/YS/poky-dora-10.0.1.tar.bz2 http://downloads.yoctoproject.org/releases/yocto/yocto-1.5.1/poky-dora-10.0.1.tar.bz2
cd ~/YS
tar -vxjf poky-dora-10.0.1.tar.bz2
mv poky-dora-10.0.1 poky
source poky/oe-init-build-env

echo -e "ALTERING conf/local.conf... in $(pwd)"
sed -i "s/MACHINE ??= \"qemux86\"/MACHINE ??= \"qemuarm\"/g" conf/local.conf
sed -i "s/#BB_NUMBER_THREADS ?= \"4\"/BB_NUMBER_THREADS ?= \"$(cat /proc/cpuinfo |grep processor|wc -l)\"/g" conf/local.conf
sed -i "s/#PARALLEL_MAKE ?= \"4\"/PARALLEL_MAKE ?= \"$(cat /proc/cpuinfo |grep processor|wc -l)\"/g" conf/local.conf
bitbake -c fetchall core-image-sato
bitbake core-image-sato
#runqemu qemux86

#IMAGES
#wget -O http://downloads.yoctoproject.org/releases/yocto/yocto-1.5.1/machines/qemu/

#toolchain
bitbake -c fetchall meta-toolchain-sdk
bitbake meta-toolchain-sdk
tar xvfjC tmp/deploy/sdk/poky-*

