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
# Purpose : Yocto installer
# Usage : run with --help paramater
#

DEPLOYMENT_FOLDER="${HOME}/YoctoDeployment"
BUILD="N"

print_usage() {
    echo -e "USAGE:"
    echo -e " --deployment-folder=\"path\""
    echo -e " --build-yocto (to build it)"
    echo -e " --distros=\"distros\" (list distros in --deployment-folder)"
    echo -e " --machines="
    echo -e " --images="
}

process_parameters() {
    # process parameters
    echo "processing paramaters"
    for i in "$@"
    do
    case "$i" in
    --help) print_usage
        ;;
    --deployment-folder=*) DEPLOYMENT_FOLDER="${i#*=}"
        ;;
    --build-yocto) BUILD="Y" 
        ;;
    --distros=*) DISTROS="${i#*=}"
        ;;
    --machines=*) MACHINES="${i#*=}"
        ;;
    --images=*) IMAGES="${i#*=}"
        ;;
    *) echo "invalid option!!!" 
        print_usage
        ;;
    esac
    done
}


install_yocto() {

    if [[ -d ${DEPLOYMENT_FOLDER} ]];then
        echo -e "skipping download... folder ${DEPLOYMENT_FOLDER} already exist"
    else
        rm -rf ${DEPLOYMENT_FOLDER}
        mkdir ${DEPLOYMENT_FOLDER}
        wget -O ${DEPLOYMENT_FOLDER}/poky-dora-10.0.1.tar.bz2 http://downloads.yoctoproject.org/releases/yocto/yocto-1.5.1/poky-dora-10.0.1.tar.bz2
        cd ${DEPLOYMENT_FOLDER}
        tar -vxjf poky-dora-10.0.1.tar.bz2
        mv poky-dora-10.0.1 poky
    fi
    
    cd ${DEPLOYMENT_FOLDER}
    DISTROS=($(ls poky/meta*/conf/distro/*.conf| grep 'conf/distro/' | cut -d '/' -f 5 | cut -d '.' -f 1))
    MACHINES=($(ls poky/meta*/conf/machine/*.conf| cut -d '/' -f 5 | cut -d '.' -f 1))
    IMAGES=($(ls poky/meta*/recipe*/images/*.bb |cut -d '/' -f 5 | cut -d '.' -f 1))
    echo -e "Found following"
    echo -e "DISTROS: ${DISTROS[@]}"
    echo -e "MACHINES: ${MACHINES[@]}"
    echo -e "IMAGES: ${IMAGES[@]}"
    echo -e "\n\nRun $0 with --build-yocto"
}

build_yocto() {
    cd ${DEPLOYMENT_FOLDER}
    source poky/oe-init-build-env
    echo -e "ALTERING conf/local.conf... in $(pwd)"
    sed -i "s/MACHINE ??= \"qemux86\"/MACHINE ??= \"${MACHINES[@]}\"/g" conf/local.conf
    sed -i "s/#BB_NUMBER_THREADS ?= \"4\"/BB_NUMBER_THREADS ?= \"$(cat /proc/cpuinfo |grep processor|wc -l)\"/g" conf/local.conf
    sed -i "s/#PARALLEL_MAKE ?= \"4\"/PARALLEL_MAKE ?= \"$(cat /proc/cpuinfo |grep processor|wc -l)\"/g" conf/local.conf
    bitbake -c fetchall ${IMAGES[@]}
    bitbake ${IMAGES[@]}
    echo -e "type runqemu ${MACHINES[@]} to run emulator"
}


print_banner() {
    echo -e "Yocto 1.5.1 Installer"
}

#########################################################################################
#                                                                                       #
# MAIN FUNCTION                                                                         #
#########################################################################################

print_banner
process_parameters
install_yocto
if [[ "${BUILD}" == "Y" ]];then
    build_yocto
fi

exit $?
