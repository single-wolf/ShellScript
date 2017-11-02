#!/bin/bash
#########################################################################
# File Name: gitInit.sh
# Author: single-wolf
# mail: root@mail.zmblog.org
# Created Time: Thu 02 Nov 2017 02:11:34 PM CST
#########################################################################

repoDir='/home/MyVPS/git-repo/'
owner='MyVPS:MyVPS'

red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'

[[ $EUID -ne 0 ]] && echo -e 1>&2 "${red}ERROR :${plain} This script should be run as root!" && exit 1

[[ $# -ne 1 ]] && echo -e 1>&2 "${green}Usage :${plain} $0 project_name" && exit 1


project_name=$1
project_repo="${repoDir}${project_name}.git"
mkdir $project_repo
cd $project_repo
git --bare init
git update-server-info
chown ${owner} -R ${project_repo}
