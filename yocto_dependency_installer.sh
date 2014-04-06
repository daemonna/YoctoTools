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
# Purpose : Yocto installer for dependencies
# Usage : run with --help paramater
#

####################################################################################################
#                                                                                                  #
# DISTRO RELATED FUNCTIONS                                                                         #
####################################################################################################

#########################################
# find out type of linux distro of HOST #
#########################################
get_distro() {
  
  echo -e "checking for right Python version.."
  if [ "${HOST_PYTHON_VERSION}" == "0" ]; then
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


install_all() {
    install_essentials
    install_graphical_extras
    install_documentation
    install_adt_extras
    install_qemu
    install_nfs
}

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
  if [ ! $(id -u) == "0" ]; then
    echo -e "${RED}"
    echo -e "#######################################################"
    echo -e "# ERROR! YOU ARE NOT ROOT!                            #"
    echo -e "#######################################################"
    exit
  else
    echo -e "running as ${GREEN}${USER}${NONE}.. OK"
  fi

}


print_banner() {
    echo -e "Yocto dependency installer 0.1 (${HOST_DISTRO})"
}

print_usage() {
    echo -e "USAGE:"
    echo -e "--help"
    echo -e "--install-all"
    echo -e "--install-qemu"
    echo -e "--install-nfs"
    echo -e "--install-essentials"
    echo -e "--install-graphical_extras"
    echo -e "--install-documentation"
    echo -e "--install-adt-extras"
}

#########################################################################################
#                                                                                       #
# MAIN FUNCTION                                                                         #
#########################################################################################



for i in "$@"
do
case $i in
    --help) print_usage
        ;;
    --install-all) install_all
        ;;
    --install-qemu) install_qemu
        ;;
    --install-nfs) install_nfs 
        ;;
    --install-essentials) install_essentials
        ;;
    --install-graphical_extras) install_graphical_extras
        ;;
    --install-documentation) install_documentation
        ;;
    --install-adt-extras) install_adt_extras
        ;;
    *) echo "invalid option ${i}!!!" 
        print_usage
        exit 1
        ;;
esac
done

get_distro
print_banner
#prepare_essentials
install_all


exit $?
