#!/bin/bash  

#
# Author : peter.ducai@gmail.com 
# Homepage : 
# License : BSD http://en.wikipedia.org/wiki/BSD_license
# Copyright 2014, peter ducai
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Purpose : Yocto toolchain installer
# Usage : run with --help
#

######################################################################
#                                                                    #
# GLOBAL VALUES                                                      #
######################################################################

YOCTO_FOLDER="${HOME}/YoctoDeployment/poky"
YOCTO_BUILD_FOLDER="${HOME}/YoctoDeployment/build"
DEPLOYMENT_FOLDER="${HOME}/YoctoDeployment-toolchain"
TOOLCHAIN_list=()
ARCH="i586"



#######################################################################
#                                                                     #
# FUNCTIONS                                                           #
#######################################################################


print_usage() {
    echo -e "USAGE:"
    echo -e "--help"
    echo -e "--list-projects"
    echo -e "--project-name=*"
    echo -e "--project-path=*"
    echo -e "--add-project=*"
    echo -e "--remove-project=*"
    echo -e "--recompile-project=*"
    echo -e "--yocto-folder=*"
}



# By default, this toolchain does not build static binaries.
# use IMAGE_INSTALL_append = " somelib-staticdev"
rebuild_toolchain() {
    
    if [[ ! -d ${YOCTO_FOLDER} ]];then
        echo -e "ERROR.. deployment folder doesn\'t exist!"
    else
        cd ../${YOCTO_FOLDER}
        source poky/oe-init-build-env
        #This method has significant advantages over the previous method because it results in a toolchain installer
        # that contains the sysroot that matches your target root filesystem.
        bitbake image -c populate_sdk
    fi
    untar_toolchain
}


untar_toolchain() {
    cd ${YOCTO_BUILD_FOLDER}
    tar xvfjC tmp/deploy/sdk/poky-eglibc-* ${DEPLOYMENT_FOLDER}/   #x86_64-arm-toolchain-gmae-1.2.tar.bz2 /   
}

# Source the cross-toolchain environment setup file
source_cross_toolchain() {
    source environment-setup-${ARCH}-poky-linux
}








#########################################################################################
#                                                                                       #
# MAIN FUNCTION                                                                         #
#########################################################################################


health_check

for i in "$@"
do
case $i in
    --help) print_usage
        ;;
    --yocto-folder=*) YOCTO_FOLDER="${i#*=}"
    --deployment-folder=*) DEPLOYMENT_FOLDER="${i#*=}"
        ;;
    --rebuild-toolchain) CLI_Project_name="${i#*=}"
        ;;
    --list-toolchains) CLI_Project_path="${i#*=}"
        ;;
    *) echo "invalid option ${i}!!!" 
        print_usage
        exit 1
        ;;
esac
done

exit $?
