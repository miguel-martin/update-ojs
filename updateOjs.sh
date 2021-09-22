#!/bin/bash

backupTo=/home/miguelm/ojs-backups/`date -Ins` # where to backup
pathToOjs=/var/www/html/ojs # path to old ojs folder
dbName=ojs # ojs dbname
apacheUser=apache # apache username
apacheGroup=apache # apache group
oldVersion=`grep 'Git tag' /var/www/html/ojs/docs/RELEASE | awk {'print $3'}` # Old version is something like 3_2_1-1
newVersionUrl=https://pkp.sfu.ca/ojs/download/ojs-3.3.0-8.tar.gz # Fill in with the corresponding url


### PRINTING COLORS ###
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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

### STOP APACHE ###
echo -e "${GREEN}Stopping Apache...${NC}"
service httpd stop

#echo -e "${GREEN}Stopping MySQL...${NC}"
#service mysqld stop

### REMOVE PREVIOUS OJS FROM htdocs ### 
echo -e "${GREEN} Deleting old ojs from $pathToOjs${NC}"
mv $pathToOjs $pathToOjs-$oldVersion #FIXME: It is already backuped, there is no need to keep another copy

### ADD NEW OJS TO htdocs ### 
echo -e "${GREEN} Moving new OJS to htdocs folder $pathToOjs ${NC}"
cd $tmpDir
mv `ls` $pathToOjs
echo -e "${GREEN} Deleting tmp dir $tmpDir ${NC}"
rm -Rf $tmpDir

### COPY OLD OJS config.inc.php file INTO NEW OJS folder ### 
echo -e "${GREEN} Copying old OJS config.inc.php to new OJS \
      ${YELLOW} [WARNING] Check RELEASE docs for changes in config.inc.php BEFORE UPDATING DATABASE ${NC}"
cd $pathToOjs
mv config.inc.php config.inc.php-ORIGINAL
cp $backupTo/ojs-$oldVersion/config.inc.php .


### COPY PUBLIC FOLDER, THEMES AND PLUGINS FROM PREVIOUS VERSION...
echo -e "${GREEN} Copying public folder to new OJS ${NC}"
cd $pathToOjs
mv public public-ORIGINAL
cp -R $backupTo/ojs-$oldVersion/public .

#echo -e "${GREEN} Copying plugins folder to new OJS ${NC}"
#cd $pathToOjs
#mv plugins plugins-ORIGINAL
#cp -R $backupTo/ojs-$oldVersion/plugins .

### COPY QUICKSUBMIT PLUGIN FROM PREVIOUS VERSION TO NEW VERSION...
echo -e "${GREEN} Copying quickSubmit plguin folder to new OJS ${NC}"
cp $pathToOjs
cp -R  $backupTo/ojs-$oldVersion/plugins/importexport/quickSubmit ./plugins/importexport/

### PREPARE TO UPDATE ###

echo -e "${GREEN}Editing config.inc.php and change 'installed = On' to 'installed = Off' ${NC}"
sed -i 's/installed = On/installed = Off/' $pathToOjs/config.inc.php

echo -e "${GREEN}Running OJS update script...${NC}"
cd $pathToOjs
php tools/upgrade.php upgrade

echo -e "${GREEN}Edit config.inc.php and change 'installed = Off' to 'installed = On' ${NC}"
sed -i 's/installed = Off/installed = On/' $pathToOjs/config.inc.php

cd $pathToOjs
chown -R $apacheUser:$apacheGroup *

### START APACHE ###

#echo -e "${GREEN}Starting MySQL...${NC}"
#service mysqld start

echo -e "${GREEN}Starting Apache...${NC}"
service httpd start
