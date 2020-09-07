#!/bin/bash


###################################
##### THIS IS A DEPLOY SCRIPT #####
###################################


# All servers=("server1", "server2", "server3")


#################
### Variables ###

# $DOMAIN variable from $DOMAIN renew script
DOMAIN="$1"

# Server list to work on.
SERVER=("${!2}")

### FUNKY MAGIC. ###
echo "DOMAIN=$DOMAIN" >/dev/null
echo "SERVERS array=${SERVERS[@]}"  > /dev/null
echo "SERVERS #elem=${#SERVERS[@]}" > /dev/null

# Auto-SSL folder location.
AUTOSSL="/home/$USER/auto-ssl"

# Letsencrypt path.
ARCHIVE="/etc/letsencrypt/archive"
LIVE="/etc/letsencrypt/live"

# Console Output Colors.
RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m'

# Logging function.
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1> /home/$USER/auto-ssl/master/logs/domains/$DOMAIN/$NOW-DEPLOY.log 2>&1


##############################################
### Creates staging folders if not present ###

# Checks for folders on control server.
printf "${RED}$s\nChecking Control Configuration$s\n$s\n${NC}"
if [ ! -d $AUTOSSL ]; then

	# Creates auto-ssl folder.
        mkdir -v $AUTOSSL

	# Creates live & archive subdirectories.
        cd $AUTOSSL && mkdir -v live && mkdir -v archive
	chmod -v 700 $AUTOSSL
        printf "${GREEN}Folders Created On Control$s\n$s\n${NC}"
fi

# Loop for remaining servers.
for SERVER in "${SERVERS[@]}"
do
        printf "${GREEN}Checking Folders on $SERVER$s\n${NC}"
        if ssh -tty $SERVER "[ ! -d "$AUTOSSL" ]"; then
        ssh -tty $SERVER "mkdir -v $AUTOSSL"
	ssh -tty $SERVER "cd $AUTOSSL && mkdir -v live && mkdir -v archive"
	ssh -tty $SERVER "chmod -v 700 $AUTOSSL"
	printf "${GREEN}Folders Created On $SERVER$s\n$${NC}"	
	fi
done


##############################################
### Prepares staging folder with SSL files ###

# Checks for $DOMAIN folders.
printf "${RED}$s\nCopying SSL Files On Control$s\n$s\n${NC}"
if [ ! -d $AUTOSSL/archive/$DOMAIN ]; then
	
	# Safely removes secrets.
	printf "${RED}Cleaning Staging Folders$s\n${NC}"
	sudo shred -vfuz $AUTOSSL/archive/$DOMAIN/*
	
	# Removes folders to deny version problems.
	sudo rm -rvf $AUTOSSL/archive/$DOMAIN
	sudo rm -rvf $AUTOSSL/live/$DOMAIN
        printf "${GREEN}Control Staging Folders Cleaned$s\n${NC}"
fi

# Copies SSL files from Letsencrypt to auto-ssl.
sudo cp -vr $ARCHIVE/$DOMAIN $AUTOSSL/archive/
sudo cp -vr $LIVE/$DOMAIN $AUTOSSL/live/

# Sets correct permissions to read for rsync.
sudo chmod -v 644 $AUTOSSL/archive/$DOMAIN/privkey.pem

# Sets correct owner and group for rsync.
sudo chown -v entermedia $AUTOSSL && sudo -v chgrp entermedia $AUTOSSL
printf "${GREEN}Control Staging Folder Set$s\n$s\n${NC}"


##############################
### Starts renewal process ###

# Loop for servers.
for SERVER in "${SERVERS[@]}"
do
	printf "${RED}$s\nSTARTING SSL DEPLOY ON $SERVER$s\n$s\n${NC}"

	# Safely removes secrets and folders to deny version problems.
	printf "${RED}$s\nCleaning On $SERVER$s\n${NC}"
	ssh -tty $SERVER "sudo shred -vfuz $AUTOSSL/archive/$DOMAIN/*"
        ssh -tty $SERVER "sudo rm -rvf $AUTOSSL/archive/$DOMAIN"
        ssh -tty $SERVER "sudo rm -rvf $AUTOSSL/live/$DOMAIN"
	printf "${GREEN}$SERVER Cleaned$s\n$s\n${NC}"
        
	# RSYNC the SSL folders & files to servers.
	printf "${GREEN}$s\nStarting File Upload On $SERVER$s\n${NC}"
	rsync -azvPi $AUTOSSL/live/$DOMAIN $SERVER:$AUTOSSL/live
        rsync -azvPi $AUTOSSL/archive/$DOMAIN $SERVER:$AUTOSSL/archive
	printf "${GREEN}Files Uploaded On $SERVER$s\n${NC}"
        
	# Copies SSL from auto-ssl staging folder to Letsencrypt.
	printf "${RED}$s\nCopying SSL Files To Letsencrypt on $SERVER$s\n${NC}"
	ssh -tty $SERVER "sudo cp -rvf $AUTOSSL/archive/$DOMAIN $ARCHIVE"
        ssh -tty $SERVER "sudo cp -rvf $AUTOSSL/live/$DOMAIN $LIVE"
        
	# Sets proper permissions, owner, and group. Reloads NGINX to push changes.
	ssh -tty $SERVER "sudo chown -v root $ARCHIVE/$DOMAIN && sudo chgrp -v root $LIVE/$DOMAIN"
	ssh -tty $SERVER "sudo chmod -v 600 $ARCHIVE/$DOMAIN/privkey.pem && sudo nginx -vs reload"
	printf "${GREEN}$s\nCopied & Set Permissions on $SERVER$s\n${NC}"

	# Cleans auto-ssl staging folder on servers.
	printf "${RED}$s\nCleaning Staging Folders On $SERVER$s\n${NC}"
	ssh -tty $SERVER "sudo shred -vfuz $AUTOSSL/archive/$DOMAIN/*"
        ssh -tty $SERVER "sudo rm -rvf $AUTOSSL/archive/$DOMAIN"
        ssh -tty $SERVER "sudo rm -rvf $AUTOSSL/live/$DOMAIN"
	printf "${GREEN}$s\nStaging Folders Cleaned On $SERVER$s\n${NC}"

	printf "${GREEN}$SERVER SSL Deploy Completed$s\n$s\n${NC}"
done

#############################
### Cleans staging folder ###
printf "${RED}$s\Control Staging Folder Cleaned$s\n${NC}"
sudo shred -fuz $AUTOSSL/archive/$DOMAIN/*
sudo rm -rvf $AUTOSSL/archive/$DOMAIN
sudo rm -rvf $AUTOSSL/live/$DOMAIN
printf "${GREEN}Control Staging Folder Cleaned$s\n${NC}"

exit 0 
