#!/bin/bash -e
# 5-verify_install.sh
# Author: Aaron Luna
# Website: alunablog.com
#
# This script modifies all folders and files which are accessed by the
# NGINX worker account (www-data) and changes ownership to this user and
# modifies the permissions to give full access to this user and R+X 
# permissions to all others.
#
# Then, the NGINX and PHP-FPM services are started (MySQL is already 
# running). If any of the three services is not running, the script is
# aborted. If all three are running, the server is rebooted to verify that
# they all start automatically on reboot.
##########################################################################

##########################################################################
# Environment Variables 
#
# DO NOT EDIT THESE VALUES IN THIS FILE, THESE VARIABLES ARE DEFINED IN
# THE PACKER TEMPLATE AND SHARED ACROSS SHELL SCRIPTS. MAKE ANY CHANGES
# TO THESE VARIABLES IN THE PACKER TEMPLATE JSON FILE.

INSTALL_LOG_FOLDER_PATH=${WORKING_DIR}/${LOG_FOLDER}
INSTALL_LOG_FILE_PATH=${INSTALL_LOG_FOLDER_PATH}/${LOG_FILE}
WP_INSTALL_FOLDER=${WP_ROOT_DIR}/${WP_HOST}

##########################################################################

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Modifying file permissions for NGINX & WP..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo chown -R www-data:www-data /etc/nginx/
sudo chmod -R 755 /etc/nginx/

sudo chown -R www-data:www-data /var/lib/nginx/
sudo chmod -R 755 /var/lib/nginx/

sudo touch /var/log/nginx/access.lob
sudo touch /var/log/nginx/error.log
sudo chown -R www-data:www-data /var/log/nginx/
sudo chmod -R 755 /var/log/nginx

sudo chown -R www-data:www-data /etc/php/
sudo chmod -R 755 /etc/php/

sudo chown -R www-data:www-data ${WP_INSTALL_FOLDER}/
sudo chmod -R 755 ${WP_INSTALL_FOLDER}/

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Verifying MySQL, NGINX & PHP-FPM services are configured correctly..." |& tee -a ${INSTALL_LOG_FILE_PATH}

sudo systemctl status mysql.service | grep -q 'Active: active (running)' > /dev/null 2>&1
if [ "$?" -gt "0" ]; then
  # if the MySQL service is not Active, there is a configuration
  # error, so the exit code is set to 1 and the script is aborted
  echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | MySQL did not start correctly, aborting script" |& tee -a ${INSTALL_LOG_PATH}
  exit 1
fi
      
echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | MySQL is running, service is configured correctly" |& tee -a ${INSTALL_LOG_FILE_PATH}

echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | Attempting to start NGINX..." |& tee -a ${INSTALL_LOG_FILE_PATH} && \
  # Start and enable NGINX service
  sudo systemctl start nginx.service >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
    sudo systemctl enable nginx.service >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
      # Verify NGINX is running
      sudo systemctl status nginx.service | grep -q 'Active: active (running)' > /dev/null 2>&1
      if [ "$?" -gt "0" ]; then
        # if the NGINX service is not Active, there is a configuration
        # error, so the exit code is set to 1 and the script is aborted
        echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | NGINX did not start correctly, aborting script" |& tee -a ${INSTALL_LOG_PATH}
        exit 1
      fi
      
echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | NGINX is running, service is configured correctly" |& tee -a ${INSTALL_LOG_FILE_PATH}
      
echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | Attempting to start PHP-FPM..." |& tee -a ${INSTALL_LOG_PATH}
  # Start and enable PHP7.0-FPM service
  sudo systemctl start php7.0-fpm.service >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
    sudo systemctl enable php7.0-fpm.service >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
      # Verify PHP7.0-FPM is running
      sudo systemctl status php7.0-fpm.service | grep -q 'Active: active (running)' > /dev/null 2>&1
      if [ "$?" -gt "0" ]; then
        # if the PHP7.0-FPM service is not Active, there is a configuration
        # error, so the exit code is set to 1 and the script is aborted
        echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | PHP-FPM did not start correctly, aborting script" |& tee -a ${INSTALL_LOG_FILE_PATH}
        exit 1
      fi
      
echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | PHP-FPM is running, service is configured correctly" |& tee -a ${INSTALL_LOG_FILE_PATH}

# Reboot the server
echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | Rebooting server...\n" |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo shutdown -r now