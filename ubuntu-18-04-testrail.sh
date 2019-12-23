#!/bin/sh
#Asking user for password
sudo echo "Please remember the following database password"
sudo echo "It will be required during the installation wizard"
read -s -p "Please enter a strong database password: " DEFAULT_PASSWORD

sudo echo ""
#Create TestRail directories
sudo echo "Creating the following TestRail Directories shortly"
sudo echo "They will be used during the installation wizard"
sudo echo "Please remember the following paths:"
sleep 3s
sudo echo "==============="
sudo echo "/opt/testrail/"
sudo echo "/opt/testrail/logs"
sudo echo "/opt/testrail/attachments"
sudo echo "/opt/testrail/reports"
sudo echo "/opt/testrail/audits"
sudo echo "==============="
sleep 3s
sudo mkdir /opt/testrail
sudo mkdir /opt/testrail/logs
sudo mkdir /opt/testrail/attachments
sudo mkdir /opt/testrail/reports
sudo mkdir /opt/testrail/audits
sudo echo "This has been completed"
sleep 1s

sudo echo "Fixing file permissions for those directories now"
sleep 3s
sudo chown www-data:www-data /opt/testrail/logs
sudo chown www-data:www-data /opt/testrail/attachments
sudo chown www-data:www-data /opt/testrail/reports
sudo chown www-data:www-data /opt/testrail/audits

sudo echo "This has been completed"
sudo echo "Running sudo apt-get update -y now"
sleep 3s
sudo apt-get update -y;
sudo echo "This has been completed!"
sudo echo "Installing Apache, PHP 7.2, Ioncube Loader 7.2, and unzip shortly..."
sleep 5s
#Installing Apache, PHP, MySQL and pre-requisites.
sudo apt-get install unzip apache2 php7.2 libapache2-mod-php7.2  php7.2-curl php7.2-mbstring php7.2-xml php7.2-zip php7.2-mysql -y -qq ;

sudo echo "This has been completed"
sudo mkdir /var/www/html/testrail/ ;
sudo echo "<?php phpinfo(); ?>" > /var/www/html/testrail/phpinfo.php ;

sudo echo "Enabling IonCube Loader now"
sudo wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip ;
sudo unzip -qq ioncube_loaders_lin_x86-64.zip ;
sudo cp ioncube/ioncube_loader_lin_7.2.so /usr/lib/php/20170718 ;
sudo echo "zend_extension=ioncube_loader_lin_7.2.so" >> /etc/php/7.2/apache2/php.ini ;
sudo echo "zend_extension=ioncube_loader_lin_7.2.so" >> /etc/php/7.2/cli/php.ini ;
sudo echo "This has been completed."

sudo echo "Restarting Apache..."
sudo systemctl restart apache2 ;
sudo echo "This has been completed"

echo "Installing MySQL 5.7 shortly..."
sleep 3s
sudo apt-get install mysql-server mysql-client -y -qq ;

sudo echo "Restarting MySQL Service..."
sudo systemctl restart mysql;
sudo echo "This has been completed"

#SQL commands to be referenced later
SQL_COMMAND_1="CREATE DATABASE testrail DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
SQL_COMMAND_2="CREATE USER 'testrail'@'localhost' IDENTIFIED BY '${DEFAULT_PASSWORD}';"
SQL_COMMAND_3="GRANT ALL ON testrail.* TO 'testrail'@'localhost';"

#Create TestRail Database and User
sudo echo "Configuring your TestRail Database now..."
mysql -u root << eof
$SQL_COMMAND_1
eof

mysql -u root << eof
$SQL_COMMAND_2
eof

mysql -u root << eof
$SQL_COMMAND_3
eof

echo "This has been completed"
echo "Running MySQL Secure installation now"
echo "Please read carefully"
sleep 4s
mysql_secure_installation

sudo echo "This has been completed"
sudo echo "Activating the TestRail background task now"
sudo echo "* * * * * www-data /usr/bin/php /var/www/html/testrail/task.php" >> /etc/cron.d/testrail
sudo echo "This has been completed"
sudo echo "Please proceed with the installation wizard via browser now"
