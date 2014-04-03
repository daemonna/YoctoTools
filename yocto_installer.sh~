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



#extract FS
#cd ~
#source /opt/poky/1.5.1/environment-setup-i586-poky-linux
#runqemu-extract-sdk \
#~/Downloads/core-image-sato-sdk-qemux86-2011091411831.rootfs.tar.bz2 $HOME/qemux86-sato

#build toolchain
#bitbake image -c populate_sdk
#. This method has significant advantages over the previous method because it results in a toolchain installer that contains the sysroot that matches your target root filesystem.


4.1.1. Creating and Running a Project Based on GNU Autotools

Follow these steps to create a simple autotools-based project:

Create your directory: Create a clean directory for your project and then make that directory your working location:

     $ mkdir $HOME/helloworld
     $ cd $HOME/helloworld
                    
Populate the directory: Create hello.c, Makefile.am, and configure.in files as follows:

For hello.c, include these lines:

     #include <stdio.h>

     main()
        {
           printf("Hello World!\n");
        }
                            
For Makefile.am, include these lines:

     bin_PROGRAMS = hello
     hello_SOURCES = hello.c
                            
For configure.in, include these lines:

     AC_INIT(hello.c)
     AM_INIT_AUTOMAKE(hello,0.1)
     AC_PROG_CC
     AC_PROG_INSTALL
     AC_OUTPUT(Makefile)
                            
Source the cross-toolchain environment setup file: Installation of the cross-toolchain creates a cross-toolchain environment setup script in the directory that the ADT was installed. Before you can use the tools to develop your project, you must source this setup script. The script begins with the string "environment-setup" and contains the machine architecture, which is followed by the string "poky-linux". Here is an example that sources a script from the default ADT installation directory that uses the 32-bit Intel x86 Architecture and using the dora Yocto Project release:

     $ source /opt/poky/1.5.1/environment-setup-i586-poky-linux
                    
Generate the local aclocal.m4 files and create the configure script: The following GNU Autotools generate the local aclocal.m4 files and create the configure script:

     $ aclocal
     $ autoconf
                    
Generate files needed by GNU coding standards: GNU coding standards require certain files in order for the project to be compliant. This command creates those files:

     $ touch NEWS README AUTHORS ChangeLog
                    
Generate the configure file: This command generates the configure:

     $ automake -a
                    
Cross-compile the project: This command compiles the project using the cross-compiler:

     $ ./configure ${CONFIGURE_FLAGS}
                    
Make and install the project: These two commands generate and install the project into the destination directory:

     $ make
     $ make install DESTDIR=./tmp
                    
Verify the installation: This command is a simple way to verify the installation of your project. Running the command prints the architecture on which the binary file can run. This architecture should be the same architecture that the installed cross-toolchain supports.

     $ file ./tmp/usr/local/bin/hello
                    
Execute your project: To execute the project in the shell, simply enter the name. You could also copy the binary to the actual target hardware and run the project there as well:

     $ ./hello
                    
As expected, the project displays the "Hello World!" message.

4.1.2. Passing Host Options

For an Autotools-based project, you can use the cross-toolchain by just passing the appropriate host option to configure.sh. The host option you use is derived from the name of the environment setup script found in the directory in which you installed the cross-toolchain. For example, the host option for an ARM-based target that uses the GNU EABI is armv5te-poky-linux-gnueabi. You will notice that the name of the script is environment-setup-armv5te-poky-linux-gnueabi. Thus, the following command works:

     $ ./configure --host=armv5te-poky-linux-gnueabi \
        --with-libtool-sysroot=<sysroot-dir>
            
This single command updates your project and rebuilds it using the appropriate cross-toolchain tools.

Note
If configure script results in problems recognizing the --with-libtool-sysroot=<sysroot-dir> option, regenerate the script to enable the support by doing the following and then run the script again:
     $ libtoolize --automake
     $ aclocal -I ${OECORE_NATIVE_SYSROOT}/usr/share/aclocal \
        [-I <dir_containing_your_project-specific_m4_macros>]
     $ autoconf
     $ autoheader
     $ automake -a
                
4.2. Makefile-Based Projects

For a Makefile-based project, you use the cross-toolchain by making sure the tools are used. You can do this as follows:

     CC=arm-poky-linux-gnueabi-gcc
     LD=arm-poky-linux-gnueabi-ld
     CFLAGS=”${CFLAGS} --sysroot=<sysroot-dir>”
     CXXFLAGS=”${CXXFLAGS} --sysroot=<sysroot-dir>”
        
