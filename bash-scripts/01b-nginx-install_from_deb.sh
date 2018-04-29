#!/bin/bash -e
# 01b-install_nginx_no_dl.sh
# Author: Aaron Luna
# Website: alunablog.com
#
# This script installs NGINX using the .deb package and source code
# archive (.tar.gz) produced from 01a-build_nginx_from_source.sh. 
#
# The .deb file and archive are uploaded to the host machine and not 
# downloaded as in 01a-build_nginx_from_source.sh. So, for example, this 
# script would be useful for a scenario where internet access is not
# available on the host machine, or you must install NGINX on several
# different OS variants for compatibility testing.
##########################################################################
# Environment Variables DO NOT EDIT THESE VALUES
#

EXT_TAR=.tar.gz
NGINX_PRE=nginx-

SRC_FOLDER_PATH=${WORKING_DIR}/${SRC_FOLDER}
INSTALL_LOG_FOLDER_PATH=${WORKING_DIR}/${LOG_FOLDER}
INSTALL_LOG_FILE_PATH=${INSTALL_LOG_FOLDER_PATH}/${LOG_FILE}
ALL_SRC_FILES_TAR=${NGINX_PRE}${NGINX_VER}-${SRC_FOLDER}${EXT_TAR}
DEB_PKG_FILE=nginx_${NGINX_VER}-1_amd64.deb

##########################################################################

# Directory where NGINX log files reside is not created when installation
# is performed using .deb package file, but it is created when NGINX is
# built from source
sudo mkdir -p /var/log/nginx

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Extracting source files from archive..." |& tee -a ${INSTALL_LOG_FILE_PATH}

cd $SRC_FOLDER_PATH
sudo tar xzf $ALL_SRC_FILES_TAR >> ${INSTALL_LOG_FILE_PATH} 2>&1

echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | Installing NGINX from .deb package...\n" |& tee -a ${INSTALL_LOG_FILE_PATH}

cd ${NGINX_PRE}${NGINX_VER}
sudo mv $SRC_FOLDER_PATH/$DEB_PKG_FILE . >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo dpkg -i ${DEB_PKG_FILE} |& tee -a ${INSTALL_LOG_FILE_PATH}
