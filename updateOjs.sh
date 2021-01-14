#!/bin/bash

backupTo=/home/miguelm/ojs-backups/`date -Ins` # where to backup
pathToOjs=/var/www/html/ojs # path to old ojs folder
dbName=ojs # ojs dbname
oldVersion=`grep 'Git tag' /var/www/html/ojs/docs/RELEASE | awk {'print $3'}` # Old version is something like 3_2_1-1
newVersionUrl=https://pkp.sfu.ca/ojs/download/ojs-3.2.1-2.tar.gz # Fill in with the corresponding url


### PRINTING COLORS ###
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


### DOWNLOAD NEW OJS ###

tmpDir=/tmp/update-ojs/`date -Ins`
echo -e "${GREEN}Creating tmp dir $tmpDir ${NC}"
mkdir -p $tmpDir
cd $tmpDir
rm -Rf *

echo -e "${GREEN}Downloading OJS from $newVersionUrl to $tmpDir ${NC}"
wget $newVersionUrl

echo -e "${GREEN}Uncompressing `ls`...${NC}"
tar -xzf `ls`

echo -e "${GREEN}Removing tar (it is no longer needed)${NC}"
rm -f *.tar.gz


### BACKUP OLD OJS ### 

echo -e "${GREEN}Creating backup dir $backupTo ${NC}"
mkdir -p $backupTo

echo -e "${GREEN}Backup files to backup dir $backupTo ${NC}"
cp -aR $pathToOjs $backupTo/ojs-$oldVersion

echo -e "${GREEN}Dumping database to backup dir $backupTo ${NC}"
mysqldump -u root -p $dbName > $backupTo/`date -Ins`.sql


### REMOVE PREVIOUS OJS FROM htdocs ### 
echo 'Deleting old ojs...'
mv $pathToOjs $pathToOjs-$oldVersion #FIXME: It is already backuped, there is no need to keep another copy

### ADD NEW OJS TO htdocs ### 
echo 'Moving new OJS to htdocs folder '$pathToOjs
cd $tmpDir
mv `ls` $pathToOjs
echo 'Deleting tmp dir '$tmpDir
rm -Rf $tmpDir

### COPY OLD OJS config.inc.php file INTO NEW OJS folder ### 
echo 'Copying old OJS config.inc.php to new OJS \
      [WARNING] Check RELEASE docs for changes in config.inc.php BEFORE UPDATING DATABASE'
cd $pathToOjs
mv config.inc.php config.inc.php-ORIGINAL
cp $backupTo/ojs-$oldVersion/config.inc.php .


### PREPARE TO UPDATE ###
#echo 'Stopping Apache...'
#service httpd stop
#
#echo 'Stopping MySQL...'
#service mysqld stop
#
#echo 'Edit config.inc.php and change installed = On to installed = Off'
#sed -i 's/installed = On/installed = Off/' $pathToOjs/config.inc.php
#
#echo 'Running OJS update script...'
#cd $pathToOjs
#php tools/upgrade.php upgrade
#
#echo 'Edit config.inc.php and change installed = On to installed = Off'
#sed -i 's/installed = Off/installed = On/' $pathToOjs/config.inc.php
#
#echo 'Starting MySQL...'
#service mysqld start
#
#echo 'Starting Apache...'
#service httpd start






