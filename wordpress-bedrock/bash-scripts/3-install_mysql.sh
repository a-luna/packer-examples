#!/bin/bash -e
# 3-install_mysql.sh
# Author: Aaron Luna
# Website: alunablog.com
# 
# This script performs a competely unassisted installation of MySQL server
# and client. At some point MySQL 5.6+ was updated to make it more difficult 
# to perform the install this way. In order to do so, this script utilizes
# debconf-set-selections to perform the initial install, and installs
# expect to secure the MySQL server.
#
# See gist link below for more info:
# https://gist.github.com/sheikhwaqas/9088872
##########################################################################

##########################################################################
# Environment Variables 
#
# DO NOT EDIT THESE VALUES IN THIS FILE, THESE VARIABLES ARE DEFINED IN
# THE PACKER TEMPLATE AND SHARED ACROSS SHELL SCRIPTS. MAKE ANY CHANGES
# TO THESE VARIABLES IN THE PACKER TEMPLATE JSON FILE.

INSTALL_LOG_FOLDER_PATH=${WORKING_DIR}/${LOG_FOLDER}
INSTALL_LOG_FILE_PATH=${INSTALL_LOG_FOLDER_PATH}/${LOG_FILE}

##########################################################################

# Install MySQL
echo "$(date +"%d-%b-%Y-%H-%M-%S") | Installing MySQL..." |& tee -a ${INSTALL_LOG_FILE_PATH}
export DEBIAN_FRONTEND=noninteractive
echo debconf mysql-server/root_password password $MYSQL_ROOT_TEMP_PASSWORD | sudo debconf-set-selections
echo debconf mysql-server/root_password_again password $MYSQL_ROOT_TEMP_PASSWORD | sudo debconf-set-selections
sudo apt -qq install mysql-server mysql-client -y >> ${INSTALL_LOG_FILE_PATH} 2>&1

# Install Expect
sudo apt -qq install expect -y >> ${INSTALL_LOG_FILE_PATH} 2>&1

# Build Expect script
tee ~/secure_mysql.sh > /dev/null << EOF
spawn $(which mysql_secure_installation)

expect "Enter password for user root:"
send "$$MYSQL_ROOT_TEMP_PASSWORD\r"

expect "Press y|Y for Yes, any other key for No:"
send "y\r"

expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:"
send "2\r"

expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "n\r"

expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"

EOF

# Run Expect script.
# This runs the "mysql_secure_installation" script which removes insecure defaults.
echo "$(date +"%d-%b-%Y-%H-%M-%S") | Securing MySQL server..." |& tee -a ${INSTALL_LOG_FILE_PATH}
sudo expect ~/secure_mysql.sh > /dev/null 2>&1 && rm -v ~/secure_mysql.sh
sudo apt-get -qq purge expect >> ${INSTALL_LOG_FILE_PATH} 2>&1

echo "$(date +"%d-%b-%Y-%H-%M-%S") | Creating Wordpress database..." |& tee -a ${INSTALL_LOG_FILE_PATH}
CREATE_DB="create database $WP_DB_NAME;GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO $WP_DB_USER_NAME@$WP_DB_HOST IDENTIFIED BY '$WP_DB_USER_TEMP_PASSWORD';FLUSH PRIVILEGES;"
mysql -u root --password=$MYSQL_ROOT_TEMP_PASSWORD -e "$CREATE_DB" >> ${INSTALL_LOG_FILE_PATH} 2>&1

SHOW_DB="SHOW DATABASES"
CHECK_DB=$(mysql -u root --password=$MYSQL_ROOT_TEMP_PASSWORD -ve "$SHOW_DB" 2>&1)
echo $CHECK_DB | grep 'wordpress' > /dev/null 2>&1
if [ "$?" -gt "0" ]; then
  echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | Database installation failed, aborting script" |& tee -a ${INSTALL_LOG_PATH}
  exit 1
fi

echo -e "$(date +"%d-%b-%Y-%H-%M-%S") | Installation complete\n" |& tee -a ${INSTALL_LOG_FILE_PATH}