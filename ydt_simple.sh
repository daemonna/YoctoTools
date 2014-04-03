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
# Purpose : Yocto development toolkit installer
# Usage : run without paramaters to see usage
#


######################
# terminal colors    #
######################

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
BLACK='\033[30m'
BLUE='\033[34m'
VIOLET='\033[35m'
CYAN='\033[36m'
GREY='\033[37m'

######################
# default values     #
######################

YOCTO_VERSION="1.5.1"
YOCTO_DISTRO="poky"
YOCTO_REPO="http://downloads.yoctoproject.org/releases/yocto/yocto-${YOCTO_VERSION}"
INSTALL_DIR="/opt/poky/1.5.1"  #default as adt installer

######################
# HOST values        #
######################

HOST_ARCH=$(uname -m)
HOST_OS=$(uname -o)
HOST_KERNEL_VERSION=$(uname -r)
CPU_THREADS=$(cat /proc/cpuinfo |grep processor|wc -l)
declare -a DISTROS=()
declare -a MACHINES=()
declare -a IMAGES=()
declare -a PACKAGE_MANAGERS=("rpm" "tar" "deb" "ipk")




#########################################################################################
#                                                                                       #
# FUNCTIONS                                                                             #
#########################################################################################

############################
# download STABLE branch   #
############################
get_stable_branch() {

    cd ${INSTALL_DIR}/${YOCTO_DISTRO}
    echo -e "downloading STABLE branch"
    wget ${YOCTO_REPO}/poky-dora-10.0.1.tar.bz2
    tar xvjf poky-dora-10.0.1.tar.bz2 
}

build_branch() {

    echo -e "[build_branch] initialized"
    cd ${INSTALL_DIR}
    # source directory to default 'build' dir
    source ${YOCTO_DISTRO}/oe-init-build-env

    #TODO check if multiple machines can be in config
    # change MACHINE in conf/local.conf
    sed -i "s/MACHINE ??= \"qemux86\"/MACHINE ??= \"${MACHINES[@]}\"/g" conf/local.conf

    #run bitbake and build
    echo -e "downloading IMAGES"
    bitbake -c fetchall ${IMAGES[@]}  #first just fetch all packages
    echo -e "RUNNING BITBAKE..................."
    bitbake ${IMAGES[@]}  #then build YOCTO
}

build_sdk() {

    echo -e "[build_sdk] initialized"    
    cd ${INSTALL_DIR}
    ls
    # source directory to default 'build' dir
    echo -e "source ${YOCTO_DISTRO}/oe-init-build-env"
    source ${YOCTO_DISTRO}/oe-init-build-env

    #TODO check if multiple machines can be in config
    # change MACHINE in conf/local.conf
    echo -e "changing conf/local.conf"
    sed -i "s/MACHINE ??= \"qemux86\"/MACHINE ??= \"${MACHINES[@]}\"/g" conf/local.conf

    # build sdk
    echo -e "RUNNING BITBAKE..................."
    bitbake -c do_populatesdk ${IMAGES[@]}  
}


#############################
# download CURRENT branch   #
#############################
get_current_branch() {

    echo -e "downloading CURRENT branch"
    if [[ -d ${INSTALL_DIR}/${YOCTO_DISTRO} ]];then
        echo "folder ${INSTALL_DIR}/${YOCTO_DISTRO} already exist!"
        cd ${INSTALL_DIR}/${YOCTO_DISTRO}
        
        # if .git exist, then we got working CURRENT branch
        if [[ -d ${INSTALL_DIR}/${YOCTO_DISTRO}/.git ]];then
            echo -e "updating with git."
            git pull
        else
            echo -e "YOCTO folder already exist but it's not GIT repository. Please delete it and rerun installer."
            exit
        fi
        echo "ex"
    else
        cd ${INSTALL_DIR}
        git clone git://git.yoctoproject.org/${YOCTO_DISTRO}
    fi
}


############################################################
# collect info from user about distro, machine and image   #
############################################################
collect_yocto_details() {

    echo -e "processing Yocto details....................................."
        
    DISTROS=($(ls ${INSTALL_DIR}/${YOCTO_DISTRO}/meta*/conf/distro/*.conf| grep 'conf/distro/' | cut -d '/' -f 9 | cut -d '.' -f 1))
    MACHINES=($(ls ${INSTALL_DIR}/${YOCTO_DISTRO}/meta*/conf/machine/*.conf| cut -d '/' -f 9 | cut -d '.' -f 1))
    IMAGES=($(ls ${INSTALL_DIR}/${YOCTO_DISTRO}/meta*/recipe*/images/*.bb |cut -d '/' -f 9 | cut -d '.' -f 1))
    
    echo -e "collecting user data........................................."
    echo -e "............................................................."

    # get info about DISTRO
    echo -e "Which DISTRO you want to use?"
    echo -e "[${DISTROS[@]}]:"

    read DST  

    if [[ -z "${DST}" ]];then
        #echo "using orig. value: ${DISTROS[@]}"
        echo "."
    else
        DISTROS="${DST}"        
    fi
    echo "using ${DISTROS[@]}"
    echo -e "............................................................."
    
    
    # get info about MACHINE
    echo -e "Which MACHINE you want to use?"
    echo -e "[${MACHINES[@]}]:"

    read MCH  

    if [[ -z "${MCH}" ]];then
        #echo "using orig. value: ${MACHINES[@]}"
        echo "."
    else
        MACHINES="${MCH}"        
    fi
    echo "using ${MACHINES[@]}"
    echo -e "............................................................."
    
    
    # get info about MACHINE
    echo -e "Which IMAGE you want to use?"
    echo -e "[${IMAGES[@]}]:"

    read IMG  

    if [[ -z "${IMG}" ]];then
        #echo "using orig. value: ${IMAGES[@]}"
        echo "."
    else
        IMAGES="${IMG}"        
    fi
    echo "using ${IMAGES[@]}"
    echo -e "............................................................."
    
    echo -e "END OF PROCESSING"
}



############################
# collect info from user   #
############################
collect_user_data() {

    echo -e "collecting user data........................................."
    echo -e "............................................................."

    # CPU THREADS setting, if user set more threads than CPU have, warning is issued and script exits
    echo -e "Your machine has ${CPU_THREADS} cores/thread. How many of them you want to use for building?"
    printf "[${CPU_THREADS}]:"

    read THR  

    if [[ -z "${THR}" ]];then
        #echo "using orig. value: ${CPU_THREADS}"
        echo "."
    else
        #echo "want to set $THR threads"
        if [[ $((${THR})) > $((${CPU_THREADS})) ]];then
            echo -e "INVALID NUMBER! You try to assign ${THR} of ${CPU_THREADS} available!"
            exit
        fi
        CPU_THREADS="${THR}"        
    fi
    echo "using ${CPU_THREADS}"
    echo -e "............................................................."


    # path where Yocto will be installed
    echo -e "Where you'd like to install Yocto or it's tools?"
    printf "[${INSTALL_DIR}]:"

    read INSTD  

    if [[ -z "${INSTD}" ]];then
        #echo "using orig. value: ${INSTALL_DIR}"
        echo "."
    else
        INSTALL_DIR="${INSTD}"        
    fi
    echo "using ${INSTALL_DIR}"
    mkdir ${INSTALL_DIR}
    echo -e "............................................................."
    
    
    
    # choice between cutting-edge and stable
    echo -e "Do you want to use CURRENT (git) unstable or rather STABLE (wget) version?"
    printf "[CURRENT]:"

    read CUST  

    if [[ -z "${CUST}" ]];then
        #echo "using orig. value: ${INSTALL_DIR}"
        echo "."
    else
        INSTALL_DIR="${INSTD}"        
    fi
    
    if [[ -z "${CUST}" ]];then
        get_current_branch
    else
        echo "not empty: ${CUST}"
        if [[ ${CUST} == "STABLE" ]];then
            get_stable_branch
        else
            echo "wrong choice"
        fi
    fi
  
    echo -e "............................................................."
}

###############################
# install full yocto          #
###############################
install_full_yocto() {

  echo "full yocto (STABLE)"
  sleep 400

  cd ${INSTALL_DIR}
  wget ${YOCTO_REPO}/poky-dora-10.0.1.tar.bz2
  tar xvjf poky-dora-10.0.1.tar.bz2

  # source directory to default 'build' dir
  source ${YOCTO_DISTRO}/oe-init-build-env

  # change MACHINE in conf/local.conf
  sed -i "s/MACHINE ??= \"qemux86\"/MACHINE ??= \"${TARGETS[@]}\"/g" conf/local.conf

  echo "going to run bitbake (but sleeping 200s)"
  sleep 400
  #run bitbake and build
  bitbake -c fetchall ${IMAGE_RECIPE}  #first just fetch all packages
  bitbake ${IMAGE_RECIPE}  #then build YOCTO
}

install_full_yocto_devel() {

  cd ${INSTALL_DIR}

  echo "full yocto devel (GIT)"
  sleep 400

  if [[ -d ${INSTALL_DIR}/${YOCTO_DISTRO} ]];then
    if [[ -d ${INSTALL_DIR}/${YOCTO_DISTRO}/.git ]];then
      echo -e "YOCTO git folder already exists.. updating with git."
      git pull
    else
      echo -e "YOCTO folder already exist but it's not GIT repository. Please delete it and rerun installer."
    fi
  else
    git clone git://git.yoctoproject.org/${YOCTO_DISTRO}
  fi

  # source directory to default 'build' dir
  source ${YOCTO_DISTRO}/oe-init-build-env

  # change MACHINE in conf/local.conf
  sed -i "s/MACHINE ??= \"qemux86\"/MACHINE ??= \"${TARGETS[@]}\"/g" conf/local.conf

  echo "going to run bitbake (but sleeping 200s)"
  sleep 400
  #run bitbake and build
  bitbake -c fetchall ${IMAGE_RECIPE}  #first just fetch all packages
  bitbake ${IMAGE_RECIPE}  #then build YOCTO
}




############################
# toolchain installer      #
############################
install_toolchain_only() {
    for ta in "${TARGET_ARCHS[@]}"
    do
        # download toolchain
        echo -e "DOWNLOADING toolchain from ${YOCTO_REPO}/toolchain/${YOCTO_DISTRO}-eglibc-${HOST_ARCH}-${IMAGE_RECIPE}-${ta}-toolchain-${YOCTO_VERSION}.sh"
        #sleep 400
        wget ${YOCTO_REPO}/toolchain/${HOST_ARCH}/${YOCTO_DISTRO}-eglibc-${HOST_ARCH}-${IMAGE_RECIPE}-${ta}-toolchain-${YOCTO_VERSION}.sh
        #run toolchain installer

        # and execute toolchain installer
        echo -e "running toolchain ${YOCTO_DISTRO}-eglibc-${HOST_ARCH}-${IMAGE_RECIPE}-${ta}-toolchain-${YOCTO_VERSION}.sh"
        #sh ${YOCTO_DISTRO}-eglibc-${HOST_ARCH}-${IMAGE_RECIPE}-${ta}-toolchain-${YOCTO_VERSION}.sh
    done  
}





#########################################################################################
#                                                                                       #
# MAIN FUNCTION                                                                         #
#########################################################################################

echo -e "welcom to simple YOCTO installer"
echo -e "##################################################"

collect_user_data
collect_yocto_details

exit $?
