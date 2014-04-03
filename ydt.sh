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

YDT_DIR="${HOME}/.ydt"
LOG_FOLDER="${YDT_DIR}/log"
LOG="${LOG_FOLDER}/ydt_ng.log"
HISTORY="${YDT_DIR}/history"
CONFIG_FOLDER="${HOME}/.ydt/configs"

######################
# HOST values        #
######################

HOST_ARCH=$(uname -m)
HOST_OS=$(uname -o)
HOST_KERNEL_VERSION=$(uname -r)
CPU_THREADS=$(cat /proc/cpuinfo |grep processor|wc -l)

HOST_DISTRO="N/A"
HOST_PYTHON_VERSION=$(python -c 'import sys; print("%i" % (sys.hexversion<0x03000000))')
HOST_INSTALL_QEMU="NO"
HOST_INSTALL_NFS="NO"

declare -a DISTROS=()
declare -a MACHINES=()
declare -a IMAGES=()
declare -a PACKAGE_MANAGERS=("rpm" "tar" "deb" "ipk")

###########
# OTHER   #
###########
NOW=$(date +"%s-%d-%m-%Y")
CONFIG_TO_SAVE=""
CLI_ARGS=""  #arguments to be saved into config


#########################################################################################
#                                                                                       #
# FUNCTIONS                                                                             #
#########################################################################################

########################
# logging functions    #
########################
adt_log_write() {
  #echo "logging [$NOW] $1 [$2]"
  echo "[$NOW] $1 [$2]" >> $LOG 
}

adt_history_write() {
  #echo "history writes [$NOW] $1"
  echo "[$NOW] $1" >> $HISTORY
}


####################################################################################################
#                                                                                                  #
# DISTRO RELATED FUNCTIONS                                                                         #
####################################################################################################

#########################################
# find out type of linux distro of HOST #
#########################################
get_distro() {
  
  echo -e "checking for right Python version.."
  if [ ${HOST_PYTHON_VERSION} -eq 0 ]; then
    echo -e "${RED}[ERROR]${NONE} we require python version 2.x"
    exit
  else 
    echo -e "${GREEN}[OK]${NONE} python version is 2.x\n"
  fi

  if [ -f /etc/redhat-release ] ; then
    HOST_DISTRO='redhat'
  elif [ -f /etc/SuSE-release ] ; then
    HOST_DISTRO="suse"
  elif [ -f /etc/debian_version ] ; then
    HOST_DISTRO="debian" # including Ubuntu!
  fi
}



################################################
# install required software for current distro #
################################################
install_essentials() {

  case "${HOST_DISTRO}" in
  redhat) yum install gawk make wget tar bzip2 gzip python unzip perl patch \
     diffutils diffstat git cpp gcc gcc-c++ glibc-devel texinfo chrpath \
     ccache perl-Data-Dumper perl-Text-ParseWords
    ;;
  suse) zypper install python gcc gcc-c++ git chrpath make wget python-xml \
     diffstat texinfo python-curses patch
    ;;
  debian) apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath
    ;;
  *) echo "DISTRO error" 
    exit 1
    ;;
  esac
}


######################################
# install additional graphics libs   #
######################################
install_graphical_extras() {

  case "${HOST_DISTRO}" in
  redhat) yum install SDL-devel xterm
    ;;
  suse) zypper install libSDL-devel xterm
    ;;
  debian) apt-get install libsdl1.2-dev xterm
    ;;
  *) echo "DISTRO error"
    exit 1
    ;;
  esac
}


#####################################
# install documentation             #
#####################################
install_documentation() {

  case "${HOST_DISTRO}" in
  redhat) yum install make docbook-style-dsssl docbook-style-xsl \
     docbook-dtds docbook-utils fop libxslt dblatex xmlto
    ;;
  suse) zypper install make fop xsltproc dblatex xmlto
    ;;
  debian) apt-get install make xsltproc docbook-utils fop dblatex xmlto
    ;;
  *) echo "DISTRO error"
    exit 1
    ;;
  esac
}


########################
# install ADT extras   #
########################
install_adt_extras() {

  case "${HOST_DISTRO}" in
  redhat) yum install autoconf automake libtool glib2-devel
    ;;
  suse) zypper install autoconf automake libtool glib2-devel
    ;;
  debian) apt-get install autoconf automake libtool libglib2.0-dev
    ;;
  *) echo "DISTRO error"
    exit 1
    ;;
  esac
}

###############################
#  install qemu (default NO)  #
###############################
install_qemu() {

    case "${HOST_DISTRO}" in
    redhat) yum install qemu-kvm
      ;;
    suse) zypper install kvm
      ;;
    debian) apt-get install kvm
      ;;
    *) echo "DISTRO error"
      exit 1
      ;;
    esac
}

########################
# install NFS          #
########################
install_nfs() {

  case "${HOST_DISTRO}" in
  redhat) yum install nfs-utils nfs-utils-lib
    ;;
  suse) zypper install nfs-client
    ;;
  debian) apt-get install nfs-common
    ;;
  *) echo "DISTRO error"
    exit 1
    ;;
  esac
}






####################################################################################################
#                                                                                                  #
# INITIAL CHECKS, SELF-HEALING FEATURES, BACKUPS                                                   #                                          #################################################################################################### 

##############################################
# prepare essential folders and config files #
##############################################                                                                   
prepare_essentials() {
  echo -e "\ninitializing CHECKs"
  echo ""
  printf "checking for user rights..   "
##########################
# check if user is root  #
##########################
  if [ $(id -u) == "0" ]; then
    echo -e "${RED}"
    echo -e "#######################################################"
    echo -e "# WARNING!!! running script as ROOT USER              #"
    echo -e "# Are you sure you want to run this script as root?   #"
    echo -e "# User access to ROOT's files can be limited!!!       #"
    echo -e "#######################################################"
    echo -e "${NONE}[Y/n]"
    read USER_INPUT
    if [[ "${USER_INPUT}" == "Y" ]];then
      printf "[OK]"
    else
      echo "exiting"
      exit
    fi
  else
    echo -e "running as as ${GREEN}${USER}${NONE}.. OK"
  fi


###############################
# check for top .ydt folder   #
###############################
  echo -e "checking for .ydt folder..."
  if [[ -d ${YDT_DIR} ]];then
    echo -e ".ydt folder found"
  else
    echo -e "you're running YDT installer for first time as ${GREEN}${USER}${NONE}"
    echo -e "no .ydt folder... creating in $HOME/.ydt ."
    mkdir ${YDT_DIR}
    echo -e "created.."
  fi
  

########################
# check log file       #
########################
  if [[ -d ${LOG_FOLDER} ]];then
    echo "${LOG_FOLDER} exists.. OK"
    adt_log_write "                               " ""
    adt_log_write "installer run by $USER" "INFO"
  else
    echo "${LOG_FOLDER} not found.. creating one"
    mkdir ${LOG_FOLDER}
    echo -e "created.."
    touch ${LOG_FOLDER}/ydt_ng.log
    echo "#created on ${NOW}" >> ${LOG_FOLDER}/ydt_ng.log
    adt_log_write "                               " "new entry"
    adt_log_write "FIRST INITIALIZATION, run by $USER" "INFO"
    adt_log_write "log file missing.. recreated in ${LOG_FOLDER}" "WARNING"
  fi


####################### 
# check CONFIG files  #
#######################
  if [[ -d $CONFIG_FOLDER ]];then
    echo "config found... OK"
  else
    echo "missing config directory... creating default one"
    mkdir $CONFIG_FOLDER
    echo "creating default config file"
    touch ${CONFIG_FOLDER}/default.config
    echo "writing default parameters into config"
    echo "#autogenerated default config" >> ${CONFIG_FOLDER}/default.config
    echo "# logged on [$NOW]"
    echo -e "--interactive" >> ${CONFIG_FOLDER}/default.config
    adt_log_write "config file missing.. recreated in ${CONFIG_FOLDER}" "WARNING"
  fi

#######################
# check HISTORY file  #
#######################
  if [[ -f ${HISTORY} ]];then
    echo "history found at ${HISTORY}... OK"
  else 
    echo "history not found... creating new one"
    echo "" > ${HISTORY}
    adt_log_write "history file missing.. recreated in ${HISTORY}" "WARNING"
    adt_history_write "history file missing.. recreated in ${HISTORY}"
  fi
}




####################################################################################################
#                                                                                                  #
# INSTALER FUNCTIONS                                                                               #                                          #################################################################################################### 


############################
# download STABLE branch   #
############################
get_stable_branch() {

    cd ${INSTALL_DIR}/${YOCTO_DISTRO}
    echo -e "downloading STABLE branch"
    cd ${INSTALL_DIR}
    wget ${YOCTO_REPO}/poky-dora-10.0.1.tar.bz2
    tar xvjf poky-dora-10.0.1.tar.bz2 
    cp -R poky-dora-10.0.1 poky
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

#############################
# build full Yocto          #
#############################
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


#############################
# build only toolchain      #
#############################
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

#######################################################
# ask user if he wants full build or just toolchain   #
#######################################################
collect_build_info() {
    
    echo -e "collecting build details....................................."
    echo -e "............................................................."

    # get info about DISTRO
    echo -e "Do you want to build full Yocto or toolchain only? (toolchain/full)"
    echo -e "[toolchain]:"

    read TLCH  

    if [[ -z "${TLCH}" ]];then
        build_sdk
    else
        build_branch     
    fi
    echo -e "............................................................."
    echo -e "FINISH......................................................."
}



####################################################################################################
#                                                                                                  #
# INTERNAL FUNCTIONS                                                                               #
####################################################################################################

##############################################
# load paramaters from specified config file #
##############################################
load_from_config() {
    CLI_ARGS=$(cat $1)
    ydt ${CLI_ARGS}
}

##############################################
# save paramaters to specified config file   #
##############################################
save_params_to_config() {
    echo -e "saving parameters to $1"
    echo $CLI_ARGS > ${YDT_DIR}/configs/$1.config
}






####################################################################################################
#                                                                                                  #
# INFO                                                                                             #
####################################################################################################

##################################
# print history of installations #
##################################
show_history() {
    echo -e "\nHISTORY.......................\n"
    cat $HISTORY 
}

list_configs() {
    echo -e "\nFollowing configs were found.."
    ls $HOME/.ydt/configs/
}

print_parameters() {
    get_distro
    echo -e "@${NOW}"
    echo -e "- ${YELLOW}HOST PARAMETERS ${NONE}------------------------------------"

    echo -e "  architecture:     ${GREEN}${HOST_ARCH}${NONE}"
    echo -e "  operating system: ${GREEN}${HOST_OS}${NONE}"
    echo -e "  kernel version:   ${GREEN}${HOST_KERNEL_VERSION}${NONE}"
    echo -e "  distribution:     ${GREEN}${HOST_DISTRO}${NONE}"
    echo -e "  CPU threads:      ${GREEN}${HOST_CPU_THREADS}${NONE}"
    echo -e "------------------------------------------------------"

    echo -e "- ${YELLOW}DISTRO PARAMETERS ${NONE}----------------------------------"
    echo -e "  distro:           ${GREEN}${YOCTO_DISTRO}${NONE}"
    echo -e "  version:          ${GREEN}${YOCTO_VERSION}${NONE}"
    echo -e "------------------------------------------------------"

    echo -e "- ${YELLOW}TARGET PARAMETERS ${NONE}----------------------------------"
    echo -e "  targets:          ${GREEN}${TARGETS[@]}${NONE}"
    echo -e "  external targets: ${GREEN}${TARGETS_EXTERNAL[@]}${NONE}"
    echo -e "  package managers: ${GREEN}${PACKAGE_MANAGERS[@]}${NONE}"
    echo -e "------------------------------------------------------"
  

    echo -e "- ${YELLOW}INSTALL PARAMETERS ${NONE}----------------------------------"
    echo -e "  install folder:   ${GREEN}${INSTALL_FOLDER}${NONE}"
    echo -e "  download folder:  ${GREEN}${DOWNLOAD_FOLDER}${NONE}"
    echo -e "  ADT repo:         ${GREEN}${YOCTO_ADT_REPO}${NONE}"
    echo -e "  log file:         ${GREEN}${LOG}${NONE}"
    echo -e "  history file:     ${GREEN}${HISTORY}${NONE}"
    echo -e "  install NFS:      ${GREEN}${HOST_INSTALL_NFS}${NONE}"
    echo -e "  install Qemu:     ${GREEN}${HOST_INSTALL_QEMU}${NONE}"
    echo -e "------------------------------------------------------"

}



print_usage() {
    echo -e "running under BASH ${BASH_VERSION}"
    echo -e ""
    echo -e "\nUsage:\n"
    echo -e "x--help                   [print help]"
    echo -e ""
    echo -e "x--install-qemu           [install Qemu package for simulation of other architectures] ROOT required!${NONE}"
    echo -e "x--install_nfs            [install NFS package] ROOT required!${NONE}"
    echo -e ""
    echo -e "x--list-parameters        [list all parameters ]"
    echo -e "--list-targets           [list all available targets (only for existing Yocto install, use with --install-path)]"
    echo -e "--set-targets          = ${GREEN}${MACHINES[@]}${NONE}"
    echo -e "                         [set targets, for more than one, separate with space]"
    echo -e "--list-rootfs            [list rootfs variables]"
    echo -e "--set-rootfs           = ${GREEN}minimal minimal-dev sato sato-dev sato-sdk lsb lsb-dev lsb-sdk${NONE}"
    echo -e "                         [external rootfs]  ${GREEN}${EXT_ROOTFS}${NONE}"
    echo -e "x--set-package-system   = ${GREEN}ipk tar deb rpm${NONE}"
    echo -e "                         [set packaging system for YOCTO]"

    echo -e "x--install-path          [specify installation path]${NONE}"
    echo -e "x--show-history          [show installation history]${NONE}"
    echo -e "x--load-from-config     = <path_to_config>${NONE}"
    echo -e "                         [load values from specified config file]${NONE}"
    echo -e "x--save-to-config       = <path_to_config>${NONE}"
    echo -e "                         [save values to specified config file]${NONE}"
    echo -e "x--list-configs           [list available config files]"
    echo -e "x--view-log               [view log file content]"
    echo -e "x--clear-log              [delete log file]"
    echo -e "--install-full-yocto     []"
    echo -e "--install-toolchain-only [ all paramaters like MACHINE, IMAGE, etc must be specified!]"
}


print_banner() {
    echo -e "\n \/ _  __|_ _                           "
    echo -e " / (_)(_ | (_) development toolkit      \n"
}


process_parameters() {
    # process parameters
    echo "processing paramaters"
    for i in "$@"
    do
    case "$i" in
    --help) print_usage
        ;;
    --show-history) show_history
        ;;
    --list-parameters) print_parameters  
        ;;
    --install-qemu) HOST_INSTALL_QEMU="YES"
        CLI_ARGS="${CLI_ARGS} --install-qemu" 
        ;;
    --install-nfs) HOST_INSTALL_NFS="YES"
        CLI_ARGS="${CLI_ARGS} --install-nfs" 
        ;;
    --list-configs) list_configs
        ;;
    --set-package-system=*) echo -e"setting package manager"
        PACKAGE_MANAGERS=(${i#*=})
        CLI_ARGS="${CLI_ARGS} --set-package-system=\"${PACKAGE_MANAGERS[@]}\""
        ;;
    --save-to-config=*) 
        CONFIG_TO_SAVE=${i#*=}
        ;;
    --install-path=*) INSTALL_DIR=${i#*=}
        echo -e"setting installation path to ${INSTALL_DIR}"
        CLI_ARGS="${CLI_ARGS} --install-path=\"${INSTALL_DIR}\"" 
        ;;
    --load-from-config=*) load_from_config ${i#*=}
        CLI_ARGS="${CLI_ARGS} --load-from-config=\"${i#*=}\""
        ;;
    --view-log) cat ${LOG}
        ;;
    --clear-log) echo "cleared by ${USER} at $NOW" > ${LOG}
        ;;
    *) echo "invalid option!!!" 
        print_usage
        ;;
    esac
    done
}




#########################################################################################
#                                                                                       #
# MAIN FUNCTION                                                                         #
#########################################################################################

print_banner
echo -e "welcome to YDT, for more options run with --help parameter"
echo -e "############################################################"
prepare_essentials

#TODO if no params, run interactive

if [[ $# -lt 1 ]];then
    echo -e "running interactive mode..."
    collect_user_data
    collect_yocto_details
    collect_build_info
else
    echo -e "running non-interactive mode..."
    process_parameters $@
    
    #if 'save to config' specified in process_parameters, save all paramaters
    if [[ ! -z ${CONFIG_TO_SAVE} ]];then
        save_params_to_config ${CONFIG_TO_SAVE}
    fi
    
    sleep 40000
    
    # Install required software 
    get_distro
    if [[ ${HOST_INSTALL_NFS} == "YES" ]];then
        install_nfs
    fi
    
    if [[ ${HOST_INSTALL_QEMU} == "YES" ]];then
        install_qemu
    fi
fi





exit $?
