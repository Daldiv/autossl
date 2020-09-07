#!/bin/bash


#####################################
##### This is THE MASTER script #####
#####################################


#################
### Variables ###

# Console Output Colors.
RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m'

# Time stamp.
NOW=$(date +"%m-%d-%Y")i
	
# Auto-ssl folder path.
AUTOSSL="/home/$USER/auto-ssl/master"
BACKUP="/home/$USER/ssl-backup"

###############
### Logging ###

# Checks for and creates domain log folder.
if [ ! -d $AUTOSSL/logs/run ]; then
        sudo mkdir -v $AUTOSSL/logs/run
fi

# Logging function.
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1> $AUTOSSL/logs/run/$NOW-MASTER.log 2>&1


###############################
### Backs up before running ###

# Checks for folders on control server.
printf "${RED}$s\nChecking Backup Folder$s\n$s\n${NC}"
if [ ! -d $BACKUP ]; then

        # Creates auto-ssl folder.
        mkdir -v $BACKUP
	chmod -v 600 $BACKUP
        printf "${GREEN}Backup Folder Created$s\n$s\n${NC}"
else
        printf "${GREEN}Backup Folder Ok$s\n$s\n${NC}"
fi

# Moves to backup folder.
printf "${RED}Backing Up Auto-SSL Folder$s\n$s\n${NC}"
cd $BACKUP

# Backups up the auto-ssl folder.
tar -cvf $NOW-backup.tar $AUTOSSL

# Moves back to master to continue.
cd $AUTOSSL
printf "${GREEN}Backup Completed$s\n$s\n${NC}"


################################
### Runs the security script ###

# Checks for and creates security log folder.
printf "${RED}$s\n$s\nRUNNING SECURITY SCRIPT$s\n$s\n${NC}"
if [ ! -d $AUTOSSL/logs/security ]; then
	sudo mkdir -v $AUTOSSL/logs/security
fi

# Deploy the SSH Keys and config files.
bash $AUTOSSL/security/security.sh

# Error catching.
if [ $? -eq 0 ]; then
	printf "${GREEN}SECURITY SCRIPT DONE$s\n$s\n${NC}"
else
	printf "${RED}$s\nSECURITY SCRIPT FAILED$s\n$s\n${NC}" >&2
	FAIL="SECURITY SCRIPT FAILED"
	ERRORPOINT="SECURITY.SH script"
	bash $AUTOSSL/audit.sh "$FAIL" "$ERRORPOINT"
fi


#######################################
### Runs the domain renewal scripts ###

# Checks for and creates domain log folder.
printf "${RED}$s\nRUNNING RENEW SCRIPTS$s\n$s\n${NC}"
for DOMAIN in $AUTOSSL/domains/*.sh
do
	# Checks for and creates domain log folder.
	if [ ! -d $AUTOSSL/logs/domains/$DOMAIN ]; then
		sudo mkdir -v $AUTOSSL/logs/domains/$DOMAIN
	fi

	# Cleans cerbot config files to avoid previous parameters.
	sudo rm -rvf /etc/letsencrypt/renewal/$DOMAIN.conf
	
	# Runs the domain renew script.
	bash $DOMAIN 
done


# Cleans up SSH keys and config.
printf "${RED}$s\nRUNNING CLEANUP SCRIPT$s\n$s\n${NC}"
sudo bash $AUTOSSL/security/cleanup.sh
printf "${GREEN}$s\nCLEANUP SCRIPT DONE$s\n$s\n${NC}"


########################
### For Audit Script ###

printf "${GREEN}$s\nCONFIRMED SUCCESS RUN$s\n${NC}"
exit 0
