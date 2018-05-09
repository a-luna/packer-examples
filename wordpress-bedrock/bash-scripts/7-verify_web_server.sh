#!/bin/bash -e
# 7-verify_web_server.sh
# Author: Aaron Luna
# Website: alunablog.com
#
# This script verifies...
##########################################################################

##########################################################################
# Environment Variables 
#
# DO NOT EDIT THESE VALUES IN THIS FILE, THESE VARIABLES ARE DEFINED IN
# THE PACKER TEMPLATE AND SHARED ACROSS SHELL SCRIPTS. MAKE ANY CHANGES
# TO THESE VARIABLES IN THE PACKER TEMPLATE JSON FILE.

INSTALL_LOG_PATH=${WORKING_DIR}/${LOG_FOLDER}/${LOG_FILE}

##########################################################################
echo "$(date +"%d-%b-%Y-%H-%M-%S") | Testing web server with HTML/PHP content..." |& tee -a ${INSTALL_LOG_PATH}

ALL_TESTS_PASS=1;

echo "$(date +"%d-%b-%Y-%H-%M-%S") | GET http://localhost/test.html" |& tee -a ${INSTALL_LOG_PATH}
TEST_HTML=$(curl http://localhost/test.html 2>/dev/null)

echo $TEST_HTML | grep -q "<html><body><p>This is a file" > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | test.html retrieved, verified content" |& tee -a ${INSTALL_LOG_PATH}
else
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | TEST FAILED!" |& tee -a ${INSTALL_LOG_PATH}
  $ALL_TESTS_PASS=0;
fi

echo "$(date +"%d-%b-%Y-%H-%M-%S") | GET http://localhost/info.php" |& tee -a ${INSTALL_LOG_PATH}
TEST_PHP=$(curl http://localhost/info.php 2>/dev/null)

echo $TEST_PHP | grep -q "<td class=\"e\">zlib.output_handler</td><td class=\"v\"><i>no value</i></td>" > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | info.php retrieved, verified content" |& tee -a ${INSTALL_LOG_PATH}
else
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | TEST FAILED!" |& tee -a ${INSTALL_LOG_PATH}
  $ALL_TESTS_PASS=0;
fi

echo "$(date +"%d-%b-%Y-%H-%M-%S") | GET http://localhost/testfpm.php" |& tee -a ${INSTALL_LOG_PATH}
TEST_PHP_FPM=$(curl http://localhost/testfpm.php 2>/dev/null)

echo $TEST_PHP_FPM | grep -q "'REQUEST_URI' => '/testfpm.php', 'SCRIPT_NAME' => '/testfpm.php'," > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | testfpm.php retrieved, verified content" |& tee -a ${INSTALL_LOG_PATH}
else
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | TEST FAILED!" |& tee -a ${INSTALL_LOG_PATH}
  $ALL_TESTS_PASS=0;
fi

echo "$(date +"%d-%b-%Y-%H-%M-%S") | GET http://localhost/testcity.php" |& tee -a ${INSTALL_LOG_PATH}
TEST_GEOIP_CITY=$(curl http://localhost/testcity.php 2>/dev/null)

echo $TEST_GEOIP_CITY | grep -q "accuracy_radius" > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
 echo "$(date +"%d-%b-%Y-%H-%M-%S") | testcity.php retrieved, verified content" |& tee -a ${INSTALL_LOG_PATH}
else
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | TEST FAILED!" |& tee -a ${INSTALL_LOG_PATH}
 $ALL_TESTS_PASS=0;
fi

echo "$(date +"%d-%b-%Y-%H-%M-%S") | GET http://localhost/testcountry.php" |& tee -a ${INSTALL_LOG_PATH}
TEST_GEOIP_COUNTRY=$(curl http://localhost/testcountry.php 2>/dev/null)

echo $TEST_GEOIP_COUNTRY | grep '美国 ) ) \[registered_country' > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | testcountry.php retrieved, verified content" |& tee -a ${INSTALL_LOG_PATH}
else
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | TEST FAILED!" |& tee -a ${INSTALL_LOG_PATH}
  $ALL_TESTS_PASS=0;
fi

echo "$(date +"%d-%b-%Y-%H-%M-%S") | GET http://localhost/wp/wp-admin/install.php" |& tee -a ${INSTALL_LOG_PATH}
TEST_WORDPRESS=$(curl http://localhost/wp/wp-admin/install.php 2>/dev/null)

echo $TEST_WORDPRESS | grep -q "<title>WordPress &rsaquo; Installation</title>" > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | Wordpress installation page retrieved, verified content" |& tee -a ${INSTALL_LOG_PATH}
else
  echo "$(date +"%d-%b-%Y-%H-%M-%S") | TEST FAILED!" |& tee -a ${INSTALL_LOG_PATH}
  $ALL_TESTS_PASS=0;
fi

if [ "$ALL_TESTS_PASS" -eq "0" ]; then
  echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | One or more HTML/PHP pages was not retrieved correctly, aborting script" |& tee -a ${INSTALL_LOG_FILE_PATH}
  exit 1
fi

echo "$(date +"%d-%b-%Y-%H-%M-%S") | All HTML/PHP test pages were retrieved" |& tee -a ${INSTALL_LOG_PATH}
echo -e "\n$(date +"%d-%b-%Y-%H-%M-%S") | Installation completed sucessfully!\n" |& tee -a ${INSTALL_LOG_PATH}