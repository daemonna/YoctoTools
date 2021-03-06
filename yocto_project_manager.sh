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
# Purpose : Yocto project management 
# Usage : run with --help
#

YOCTOTOOLS_CONFIG_FOLDER="${HOME}/.yoctotools"


PROJECTS_name=()
PROJECTS_path=()
CLI_Project_name=""
CLI_Project_path=""
NOW=$(date +"%s-%d-%m-%Y")
Project_name_file="${HOME}/.yocto_management/projects_names"
Project_path_file="${HOME}/.yocto_management/projects_paths"
DEPLOYMENT_FOLDER="${HOME}/YoctoDeployment-toolchain"

health_check() {
    if [[ -d ${DEPLOYMENT_FOLDER} ]];then
        echo -e "DEPLOYMENT_FOLDER OK"
    else
        echo -e "DEPLOYMENT_FOLDER error.. please specify path to Yocto deployment."
    fi
    
    if [[ -f ${Project_name_file} ]];then
        echo -e "Project_name_file OK"
    else
        echo -e "Project_name_file error.. recreating."
        echo -e "#project file, generated on ${NOW}" >> ${Project_name_file}
    fi
    
    if [[ -d ${Project_path_file} ]];then
        echo -e "Project_path_file OK"
    else
        echo -e "Project_path_file error.. recreating."
        echo -e "#project file, generated on ${NOW}" >> ${Project_path_file}
    fi
}

print_usage() {
    echo -e "USAGE:"
    echo -e "--help"
    echo -e "--list-projects"
    echo -e "--project-name=*"
    echo -e "--project-path=*"
    echo -e "--add-project [use only with --project-name and --project-path]"
    echo -e "--remove-project=*"
    echo -e "--recompile-project=*"
    echo -e "--setup-ssh"
    echo -e "--update-packages=* [path to library to update]"
    echo -e "--setup_environment"
}



list_projects() {
    echo -e "[list_projects]"
    cat ${Project_name_file}
}


#
# Parameters:
#   deployment_folder
#
add_deployment() {
	echo -e "adding new deployment folder... $1"
    if [[ ! -d ${YOCTOTOOLS_CONFIG_FOLDER} ]];then
        mkdir -p ${YOCTOTOOLS_CONFIG_FOLDER}
    fi

    # check for duplicate
    if [[ $(($(cat ${YOCTOTOOLS_CONFIG_FOLDER}/deployments|grep $1|wc -l))) < 1 ]];then
        echo -e "$1" >> ${YOCTOTOOLS_CONFIG_FOLDER}/deployments
    else 
        echo -e "already listed.. skipping"
    fi
}

#
# Parameters:
#   deployment_folder
#
set_default_deployment() {
    echo -e "setting default deployment to $1"
    if [[ ! -d ${YOCTOTOOLS_CONFIG_FOLDER} ]];then
        mkdir -p ${YOCTOTOOLS_CONFIG_FOLDER}
    fi

    echo -e "$1" >> ${YOCTOTOOLS_CONFIG_FOLDER}/default_deployment
}

#
# Parameters:
#   CLI_Project_name
#   CLI_Project_path
#
add_project() {
    echo -e "[add_project] $1 $2"
    #TODO check for duplicite entries in file thru wc -l
    echo -e "$1" >> ${Project_name_file}
    echo -e "$2" >> ${Project_path_file}
}

remove_project() {
    echo -e "[remove_project]"
}

recompile_project() {
    echo -e "[recompile_project] $1"
}

setup_environment() {
    echo -e "[setup_environment]"
    bash ${YOCTO_FOLDER}/environment-setup-${ARCH}-poky-linux
}

setup_ssh() {
    echo -e "[setup_ssh]"
    #meta/recipes-core/images/core-image-minimal.bb
    #meta/recipes-connectivity/openssh/openssh_6.2p2.bb
}

update_packages() {
    echo -e "[update_packages] $1"
    #bitbake ${some_lib}
    #opkg-cl –f <conf_file> -o <sysroot_dir> update
    #opkg-cl –f <cconf_file> -o <sysroot_dir> \
    #--force-overwrite install ${some_lib}
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
    --list-projects) list_projects
        ;;
    --project-name=*) CLI_Project_name="${i#*=}"
        ;;
    --project-path=*) CLI_Project_path="${i#*=}"
        ;;
    --add-project) add_project CLI_Project_name CLI_Project_path
        ;;
    --remove-project=*) remove_project "${i#*=}"
        ;;
    --recompile-project=*) recompile_project "${i#*=}"
        ;;
    --update-packages=*) update_packages "${i#*=}"
        ;;
    --setup-environment=*) setup_environment "${i#*=}"
        ;;
    --add_deployment=*) add_deployment "${i#*=}"
        ;;
    --set-default-deployment=*) set_default_deployment "${i#*=}"
        ;;
    *) echo "invalid option ${i}!!!" 
        print_usage
        exit 1
        ;;
esac
done


exit $?
