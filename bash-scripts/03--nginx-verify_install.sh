#!/bin/bash -e
# 03-verify_nginx.sh
#
# This script verifies that the nginx service is running
# and the UFW app profile settings were copied correctly.

# These variable values are set in the packer template

INSTALL_LOG_PATH=${WORKING_DIR}/${LOG_FOLDER}/${LOG_FILE}

echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | Reboot completed, NGINX service should be running:\n" |& tee -a ${INSTALL_LOG_PATH} 
sudo systemctl status nginx.service |& tee -a ${INSTALL_LOG_PATH}

sudo systemctl status nginx.service | grep -q 'Active: active (running)' > /dev/null 2>&1
if [ "$?" -gt "0" ]; then
  # if the NGINX service is not Active, there is a configuration
  # error, so the exit code is set to 1 and the script is aborted
  echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | NGINX did not start correctly, aborting script" |& tee -a ${INSTALL_LOG_PATH}
  exit 1
fi

echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | Verify 3 NGINX UFW app profiles are listed below (Full, HTTP and HTTPS):" |& tee -a ${INSTALL_LOG_PATH}
sudo ufw app list |& tee -a ${INSTALL_LOG_PATH}