#!/bin/bash -e
# 00-prepare_install.sh
# Author: Aaron Luna
# Website: alunablog.com
#
# This script creates all necessary directories and downloads software
# libraries that are required in order to run NGINX. Please note, however,
# that these libraries are not part of the source code which is used to 
# build NGINX. The libraries that are needed to build NGINX (PCRE, zlib,
# OpenSSL) are downloaded only when building from source. These libraries
# have already been downloaded when installing from the .deb patckage
##########################################################################
# Computed Environment Variables DO NOT EDIT THESE VALUES
#
INSTALL_LOG_FOLDER_PATH=${WORKING_DIR}/${LOG_FOLDER}
INSTALL_LOG_FILE_PATH=${INSTALL_LOG_FOLDER_PATH}/${LOG_FILE}
##########################################################################

sudo mkdir -p $INSTALL_LOG_FOLDER_PATH
sudo touch $INSTALL_LOG_FILE_PATH
sudo chown ubuntu:ubuntu $INSTALL_LOG_FILE_PATH

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Updating system..." |& tee -a ${INSTALL_LOG_FILE_PATH}

# Add Maxmind PPA to apt sources
sudo add-apt-repository ppa:maxmind/ppa -y >> ${INSTALL_LOG_FILE_PATH} 2>&1

# Update OS
sudo apt update >> ${INSTALL_LOG_FILE_PATH} 2>&1 && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo apt autoremove -y >> ${INSTALL_LOG_FILE_PATH} 2>&1

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Downloading prerequisites..." |& tee -a ${INSTALL_LOG_FILE_PATH}

# Install build tools (gcc, g++, etc)
sudo apt install build-essential -y >> ${INSTALL_LOG_FILE_PATH} 2>&

# Install libraries required by GeoIP2 module to read MaxMind database files
sudo apt install libmaxminddb0 libmaxminddb-dev mmdb-bin -y >> ${INSTALL_LOG_FILE_PATH} 2>&1

# Install checkinstall to create .deb package file
sudo apt install checkinstall -y >> ${INSTALL_LOG_FILE_PATH} 2>&1

# Install Uncomplicated Firewall (UFW) since NGINX app profile 
# is created after install and directory is assumed to exist
sudo apt install ufw -y >> ${INSTALL_LOG_FILE_PATH} 2>&1
