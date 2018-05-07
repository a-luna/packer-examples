#!/bin/bash -e
# 6-verify_install_reboot.sh
# Author: Aaron Luna
# Website: alunablog.com
#
# This script verifies that NGINX, MySQL and PHP-FPM services start
# automatically after the server reboots
##########################################################################

##########################################################################
# Environment Variables 
#
# DO NOT EDIT THESE VALUES IN THIS FILE, THESE VARIABLES ARE DEFINED IN
# THE PACKER TEMPLATE AND SHARED ACROSS SHELL SCRIPTS. MAKE ANY CHANGES
# TO THESE VARIABLES IN THE PACKER TEMPLATE JSON FILE.

INSTALL_LOG_PATH=${WORKING_DIR}/${LOG_FOLDER}/${LOG_FILE}

##########################################################################

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Reboot complete" |& tee -a ${INSTALL_LOG_PATH}
echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | MySQL, NGINX & PHP-FPM should be running:\n" |& tee -a ${INSTALL_LOG_PATH}

sudo systemctl status mysql.service |& tee -a ${INSTALL_LOG_PATH}
sudo systemctl status mysql.service | grep -q 'Active: active (running)' > /dev/null 2>&1
if [ "$?" -gt "0" ]; then
  # if the NGINX service is not Active, there is a configuration
  # error, so the exit code is set to 1 and the script is aborted
  echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | MySQL did not start correctly, aborting script" |& tee -a ${INSTALL_LOG_PATH}
  exit 1
fi

echo -e "\n" |& tee -a ${INSTALL_LOG_PATH}
sudo systemctl status nginx.service |& tee -a ${INSTALL_LOG_PATH}
sudo systemctl status nginx.service | grep -q 'Active: active (running)' > /dev/null 2>&1
if [ "$?" -gt "0" ]; then
  # if the NGINX service is not Active, there is a configuration
  # error, so the exit code is set to 1 and the script is aborted
  echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | NGINX did not start correctly, aborting script" |& tee -a ${INSTALL_LOG_PATH}
  exit 1
fi

sudo systemctl status php7.0-fpm.service |& tee -a ${INSTALL_LOG_PATH}
sudo systemctl status php7.0-fpm.service | grep -q 'Active: active (running)' > /dev/null 2>&1
if [ "$?" -gt "0" ]; then
  # if the PHP7.0-FPM service is not Active, there is a configuration
  # error, so the exit code is set to 1 and the script is aborted
  echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | PHP-FPM did not start correctly, aborting script" |& tee -a ${INSTALL_LOG_FILE_PATH}
  exit 1
fi

echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | Installation completed sucessfully!\n" |& tee -a ${INSTALL_LOG_PATH}