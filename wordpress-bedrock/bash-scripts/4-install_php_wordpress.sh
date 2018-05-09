#!/bin/bash -e
# 4-install_php_wordpress.sh
# Author: Aaron Luna
# Website: alunablog.com
#
# This script installs PHP7.0 and Composer before creating a new Wordpress
# bedrock project. The composer file containing the site's plugins and 
# themes is copied along with HTML/PHP files which can be used to
# troubleshoot NGINX issues.
#
# Them, the bedrock .env file is populated with the wordpress site and DB
# config settings. Finally, the C API for accessing the Maxmind GeoLite2
# database files is built from source.
##########################################################################

##########################################################################
# Environment Variables 
#
# DO NOT EDIT THESE VALUES IN THIS FILE, THESE VARIABLES ARE DEFINED IN
# THE PACKER TEMPLATE AND SHARED ACROSS SHELL SCRIPTS. MAKE ANY CHANGES
# TO THESE VARIABLES IN THE PACKER TEMPLATE JSON FILE.

SITE_FILES_FOLDER_PATH=${WORKING_DIR}/${SITE_FILES_FOLDER}
INSTALL_LOG_FOLDER_PATH=${WORKING_DIR}/${LOG_FOLDER}
INSTALL_LOG_FILE_PATH=${INSTALL_LOG_FOLDER_PATH}/${LOG_FILE}
WP_INSTALL_FOLDER=${WP_ROOT_DIR}/${WP_HOST}

#######################################################################

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Installing PHP 7.0..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo apt -y install php7.0-common php7.0-dev php7.0-cli php7.0-curl php7.0-fpm \
  php7.0-gd php7.0-json php7.0-mbstring php7.0-mysql php7.0-opcache php7.0-readline \
    php7.0-xml php7.0-zip php7.0-cgi php-pear >> ${INSTALL_LOG_FILE_PATH} 2>&1

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Installing Composer..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo mkdir -p ${WP_INSTALL_FOLDER}
cd ${WP_INSTALL_FOLDER}
sudo wget https://getcomposer.org/composer.phar >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo chmod +x composer.phar
sudo cp composer.phar /usr/local/bin/composer

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Installing Wordpress (Bedrock)..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo composer create-project roots/bedrock >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo mv ${SITE_FILES_FOLDER_PATH}/composer.json ${WP_INSTALL_FOLDER}/bedrock
cd ${WP_INSTALL_FOLDER}/bedrock
sudo composer update >> ${INSTALL_LOG_FILE_PATH} 2>&1

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Installing WP-CLI..." |& tee -a ${INSTALL_LOG_FILE_PATH}
cd ~
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >> ${INSTALL_LOG_FILE_PATH} 2>&1
chmod +x wp-cli.phar
sudo cp wp-cli.phar /usr/local/bin/wp
wp package install git@github.com:sebastiaandegeus/wp-cli-salts-command.git >> ${INSTALL_LOG_FILE_PATH} 2>&1

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Configuring Bedrock .env file..." |& tee -a ${INSTALL_LOG_FILE_PATH}
cd ${WP_INSTALL_FOLDER}/bedrock
sudo mv ${WORKING_DIR}/config_env.sh ${WP_INSTALL_FOLDER}/bedrock
sudo chmod +x ${WP_INSTALL_FOLDER}/bedrock/config_env.sh
sudo touch salts_pre
sudo chown ubuntu:ubuntu salts_pre
wp salts generate >> salts_pre
sudo ./config_env.sh $WP_DB_NAME $WP_DB_USER_NAME $WP_DB_USER_TEMP_PASSWORD $WP_DB_HOST $WP_HOST ${WP_INSTALL_FOLDER}/bedrock/salts_pre
sudo rm config_env.sh
sudo rm salts_pre
sudo rm salts_post

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Copying HTML/PHP test files..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo mv ${SITE_FILES_FOLDER_PATH}/test.html ${WP_INSTALL_FOLDER}/bedrock/web
sudo mv ${SITE_FILES_FOLDER_PATH}/info.php ${WP_INSTALL_FOLDER}/bedrock/web
sudo mv ${SITE_FILES_FOLDER_PATH}/testfpm.php ${WP_INSTALL_FOLDER}/bedrock/web
sudo mv ${SITE_FILES_FOLDER_PATH}/testcity.php ${WP_INSTALL_FOLDER}/bedrock/web
sudo mv ${SITE_FILES_FOLDER_PATH}/testcountry.php ${WP_INSTALL_FOLDER}/bedrock/web

sudo sed -i "s|  require_once '/sites/example.com/bedrock/vendor/autoload.php';|  require_once '${WP_INSTALL_FOLDER}/bedrock/vendor/autoload.php';|" ${WP_INSTALL_FOLDER}/bedrock/web/testcity.php
sudo sed -i "s|  require_once '/sites/example.com/bedrock/vendor/autoload.php';|  require_once '${WP_INSTALL_FOLDER}/bedrock/vendor/autoload.php';|" ${WP_INSTALL_FOLDER}/bedrock/web/testcountry.php

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Building Maxmind-DB C API..." |& tee -a ${INSTALL_LOG_FILE_PATH}
cd ${WP_INSTALL_FOLDER}/bedrock/vendor/maxmind-db/reader/ext
sudo phpize >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo ./configure >> ${INSTALL_LOG_FILE_PATH} 2>&1
sudo make >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
  sudo make test >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
    sudo make install >> ${INSTALL_LOG_FILE_PATH} 2>&1 && \
      sudo ldconfig >> ${INSTALL_LOG_FILE_PATH} 2>&1

sudo sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini
sudo sed -i '/^\; Dynamic Extensions/{N;N;s/$/\nextension=maxminddb.so\n/}' /etc/php/7.0/fpm/php.ini

echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | Installation complete\n" |& tee -a ${INSTALL_LOG_FILE_PATH}