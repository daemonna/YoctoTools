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
# Purpose : Yocto tools manager
# Usage : run without parameters



print_banner() {
    echo -e "YoctoTools interactive console"
}

#########################################################################################
#                                                                                       #
# MAIN FUNCTION                                                                         #
#########################################################################################

echo -e "choose task:"
echo -e "1) install Yocto dependencies"
echo -e "2) install full Yocto"
echo -e "3) install toolchain only"
echo -e "4) setup new project or add existing"

read CHOICE

for i in "${CHOICE}"
do
case $i in
    1) echo -e "using yocto_dependency_installer.sh to install all dependencies"
        yocto_dependency_installer.sh --install-all
        ;;
    2) echo -e "using yocto_15_isntaller.sh to install Yocto"
        yocto_15_installer.sh --interactive
        ;;
    3) install_qemu
        ;;
    4) install_nfs 
        ;;

    *) echo "invalid option ${i}!!!" 
        print_usage
        exit 1
        ;;
esac
done

exit $?
