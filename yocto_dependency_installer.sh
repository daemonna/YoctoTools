#!/bin/bash

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



process_parameters() {
    # process parameters
    echo "processing paramaters"
    for i in "$@"
    do
    case "$i" in
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
    --install-adt_extras) install_adt_extras
        ;;
    *) echo "invalid option!!!" 
        print_usage
        ;;
    esac
    done
}


print_banner() {
    echo -e "Yocto dependency installer 0.1 (${HOST_DISTRO})"
}

#########################################################################################
#                                                                                       #
# MAIN FUNCTION                                                                         #
#########################################################################################

get_distro
print_banner
prepare_essentials
process_parameters

exit $?
