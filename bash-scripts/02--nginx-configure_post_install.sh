#!/bin/bash -e
# 02--configure_nginx_post_install.sh
#
# This script performs various actions that are necessary
# in order for NGINX to run after installation. These tasks
# include:
#
#   - Creating directories expected by NGINX configuration test
#   - Creating folder structure to support virtual host configurations
#   - Configuring UFW app profiles for HTTP and/or HTTPS traffic
#   - Configuring systemd unit file so NGINX can be started,
#     stopped and reloaded with global commands
#   - Remove all source files used to build/install NGINX
#   - Start and enable the NGINX service, verify NGINX starts
#     without error
#   - Reboots the server to verify NGINX starts automatically when
#     reboot occurs, verified in next script 03-verify_nginx.sh
##########################################################################
# String values DO NOT EDIT THESE VALUES
#

GEOIP1_PRE=GeoLite2-City
GEOIP2_PRE=GeoLite2-Country
EXT=.tar.gz
EXT_DB=.mmdb

##########################################################################
##########################################################################
# Computed Environment Variables DO NOT EDIT THESE VALUES
#

SRC_FOLDER_PATH=${WORKING_DIR}/${SRC_FOLDER}
DEB_PKG_FOLDER_PATH=${WORKING_DIR}/${DEB_PKG_FOLDER}
INSTALL_LOG_FOLDER_PATH=${WORKING_DIR}/${LOG_FOLDER}
INSTALL_LOG_FILE_PATH=${INSTALL_LOG_FOLDER_PATH}/${LOG_FILE}

GEOIP1_DB_TAR=${GEOIP1_PRE}${EXT}
GEOIP2_DB_TAR=${GEOIP2_PRE}${EXT}

GEOIP1_DB_FOLDER=${GEOIP1_PRE}_${GEOIP_VER}
GEOIP2_DB_FOLDER=${GEOIP2_PRE}_${GEOIP_VER}

GEOIP1_DB_FILE=${GEOIP1_PRE}${EXT_DB}
GEOIP2_DB_FILE=${GEOIP2_PRE}${EXT_DB}

##########################################################################

# Create a directory at /var/lib/nginx to prevent the NGINX config 
# file from failing verification in next command (sudo nginx -t)
sudo mkdir -p /var/lib/nginx >> ${INSTALL_LOG_FILE_PATH} 2>&1

echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | Verify configuration file syntax is correct and test is successful:\n" |& tee -a ${INSTALL_LOG_FILE_PATH} && \
  # This command tests the nginx.conf file for syntax errors and other
  # potential issues like file access, permissions, etc.
  sudo nginx -t |& tee -a ${INSTALL_LOG_FILE_PATH} && \

    echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | Verify NGINX version and configure arguments match your selections:\n" |& tee -a ${INSTALL_LOG_FILE_PATH} && \
      # Verify NGINX version and verify configuration options match what
      # was specified with the ./configure command
      sudo nginx -V |& tee -a ${INSTALL_LOG_FILE_PATH} && \

        echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | Creating folders for nginx virtual hosts..." |& tee -a ${INSTALL_LOG_FILE_PATH} && \
          # Create folders for nginx virtual hosts
          cd /etc/nginx
          sudo mkdir sites-available >> ${INSTALL_LOG_FILE_PATH} 2>&1
          sudo mkdir sites-enabled >> ${INSTALL_LOG_FILE_PATH} 2>&1
          
echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | Downloading GeoIP2 database files..." |& tee -a ${INSTALL_LOG_FILE_PATH} && \
# Create directory for GeoIP2 databases
sudo mkdir -p /etc/nginx/geoip2 >> ${INSTALL_LOG_FILE_PATH} 2>&1

# Download latest versions of GeoIP2 databases and extract database files
sudo wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
  sudo tar -xzf $GEOIP1_DB_TAR $GEOIP1_DB_FOLDER/$GEOIP1_DB_FILE --strip-components 1 >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
  sudo tar -zxf $GEOIP2_DB_TAR $GEOIP2_DB_FOLDER/$GEOIP2_DB_FILE --strip-components 1  >> ${INSTALL_LOG_FILE_PATH} 2>&1

# Move GeoIP2 database files to NGINX config directory and remove .tar.gz archives
sudo mv *.mmdb /etc/nginx/geoip2 >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo rm *.tar.gz |& tee >> ${INSTALL_LOG_FILE_PATH} 2>&1

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Configuring firewall app profile..." |& tee -a ${INSTALL_LOG_FILE_PATH}
# Move the UFW app profile uploaded by the previous script to 
# the correct location. UFW is disabled by default
sudo mv ${DEB_PKG_FOLDER_PATH}/nginx /etc/ufw/applications.d/nginx

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Configuring systemd unit file..." |& tee -a ${INSTALL_LOG_FILE_PATH}
# Move the file to correct location so NGINX can be started,
# stopped and reloaded with global commands
sudo mv /${DEB_PKG_FOLDER_PATH}/nginx.service /etc/systemd/system/nginx.service

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Setting permissions for NGINX user account..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo chown www-data:www-data /run/nginx.pid
sudo chown -R www-data:www-data /var/log/nginx/*
sudo chown -R www-data:www-data /etc/nginx/*

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Installation and configuration is complete, removing source files..." |& tee -a ${INSTALL_LOG_FILE_PATH}
# Remove all source files
sudo rm -rf $SRC_FOLDER_PATH

echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | Starting NGINX, verify service is active:\n" |& tee -a ${INSTALL_LOG_FILE_PATH} && \
  # Start and enable NGINX service
  sudo systemctl start nginx.service >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
    sudo systemctl enable nginx.service >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
      # Verify NGINX is running
      sudo systemctl status nginx.service |& tee -a ${INSTALL_LOG_FILE_PATH} && \

      sudo systemctl status nginx.service | grep -q 'Active: active (running)' > /dev/null 2>&1
      if [ "$?" -gt "0" ]; then
        # if the NGINX service is not Active, there is a configuration
        # error, so the exit code is set to 1 and the script is aborted
        echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | NGINX did not start correctly, aborting script" |& tee -a ${INSTALL_LOG_FILE_PATH}
        exit 1
      fi

# Reboot the server
echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | NGINX is successfully installed and configured" |& tee -a ${INSTALL_LOG_FILE_PATH}
echo "$(date +"%d-%b-%Y-%H-%M-%S") | Rebooting server to verify NGINX starts automatically..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo shutdown -r now
