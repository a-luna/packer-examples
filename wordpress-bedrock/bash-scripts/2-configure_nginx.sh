#!/bin/bash -e
# 2-configure_nginx.sh
# Author: Aaron Luna
# Website: alunablog.com
#
# This script performs various actions that are necessary
# in order for NGINX to run after installation. These tasks
# include:
#
#   - Creating directories expected by NGINX configuration test
#   - Creating folder structure to support virtual host configurations
#   - Configuring UFW app profiles for HTTP and/or HTTPS traffic
#   - Configuring systemd unit file so NGINX can be started,
#     stopped and reloaded with global commands\
##########################################################################
# Environment Variables 
#
# DO NOT EDIT THESE VALUES IN THIS FILE, THESE VARIABLES ARE DEFINED IN
# THE PACKER TEMPLATE AND SHARED ACROSS SHELL SCRIPTS. MAKE ANY CHANGES
# TO THESE VARIABLES IN THE PACKER TEMPLATE JSON FILE.

GEOIP1_PRE=GeoLite2-City
GEOIP2_PRE=GeoLite2-Country
EXT=.tar.gz
EXT_DB=.mmdb

GEOIP1_DB_TAR=${GEOIP1_PRE}${EXT}
GEOIP2_DB_TAR=${GEOIP2_PRE}${EXT}

GEOIP1_DB_FOLDER=${GEOIP1_PRE}_${GEOIP_VER}
GEOIP2_DB_FOLDER=${GEOIP2_PRE}_${GEOIP_VER}

GEOIP1_DB_FILE=${GEOIP1_PRE}${EXT_DB}
GEOIP2_DB_FILE=${GEOIP2_PRE}${EXT_DB}

ARCHIVE_FOLDER_PATH=${WORKING_DIR}/${ARCHIVE_FOLDER}
SERVICE_CONFIG_FOLDER_PATH=${WORKING_DIR}/${SERVICE_CONFIG_FOLDER}
SITE_CONFIG_FOLDER_PATH=${WORKING_DIR}/${SITE_CONFIG_FOLDER}
SITE_FILES_FOLDER_PATH=${WORKING_DIR}/${SITE_FILES_FOLDER}
INSTALL_LOG_FOLDER_PATH=${WORKING_DIR}/${LOG_FOLDER}
INSTALL_LOG_FILE_PATH=${INSTALL_LOG_FOLDER_PATH}/${LOG_FILE}

##########################################################################

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Downloading H5BP server configs..." |& tee -a ${INSTALL_LOG_FILE_PATH}
cd /etc
sudo mv nginx nginx-previous
sudo git clone --recursive https://github.com/h5bp/server-configs-nginx.git nginx >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo mkdir -p /etc/nginx/conf.d
sudo mkdir -p /etc/nginx/snippets

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Copying NGINX configuration files..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo mv ${SITE_CONFIG_FOLDER_PATH}/fastcgi_params /etc/nginx/fastcgi_params
sudo mv ${SITE_CONFIG_FOLDER_PATH}/nginx.conf /etc/nginx/nginx.conf
sudo mv ${SITE_CONFIG_FOLDER_PATH}/ssl.conf /etc/nginx/snippets/ssl.conf
sudo mv ${SITE_CONFIG_FOLDER_PATH}/default /etc/nginx/sites-available/default
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

sudo sed -i "s|server_name localhost;|server_name ${WP_HOST};|" /etc/nginx/sites-available/default
sudo sed -i "s|root /sites/example.com/bedrock/web;|root ${WP_ROOT_DIR}/${WP_HOST}/bedrock/web;|" /etc/nginx/sites-available/default

echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | Downloading GeoIP2 database files..." |& tee -a ${INSTALL_LOG_FILE_PATH} && \
# Create directory for GeoIP2 databases
sudo mkdir -p /etc/nginx/geoip2 >> ${INSTALL_LOG_FILE_PATH} 2>&1

# Download latest versions of GeoIP2 databases and extract database files
sudo wget http://geolite.maxmind.com/download/geoip/database/$GEOIP1_DB_TAR >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
  sudo tar -xzf $GEOIP1_DB_TAR $GEOIP1_DB_FOLDER/$GEOIP1_DB_FILE --strip-components 1 >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo wget http://geolite.maxmind.com/download/geoip/database/$GEOIP2_DB_TAR >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
  sudo tar -zxf $GEOIP2_DB_TAR $GEOIP2_DB_FOLDER/$GEOIP2_DB_FILE --strip-components 1  >> ${INSTALL_LOG_FILE_PATH} 2>&1

# Move GeoIP2 database files to NGINX config directory and remove .tar.gz archives
sudo mv *.mmdb /etc/nginx/geoip2
sudo rm *.tar.gz

# Create a directory at /var/lib/nginx to prevent the NGINX config 
# file from failing verification in next command (sudo nginx -t)
sudo mkdir -p /var/lib/nginx >> ${INSTALL_LOG_FILE_PATH} 2>&1

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Setting permissions for NGINX user account..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo touch /run/nginx.pid
sudo chown www-data:www-data /run/nginx.pid
sudo chmod 755 /run/nginx.pid

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Creating firewall app profile..." |& tee -a ${INSTALL_LOG_FILE_PATH}
# Move the UFW app profile uploaded by the previous script to 
# the correct location. UFW is disabled by default
sudo mv ${SERVICE_CONFIG_FOLDER_PATH}/nginx /etc/ufw/applications.d/nginx

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Creating systemd unit file..." |& tee -a ${INSTALL_LOG_FILE_PATH}
# Move the file to correct location so NGINX can be started,
# stopped and reloaded with global commands=
sudo mv ${SERVICE_CONFIG_FOLDER_PATH}/nginx.service /etc/systemd/system/nginx.service

echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | Configuration complete\n" |& tee -a ${INSTALL_LOG_FILE_PATH}