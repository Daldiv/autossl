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
AUTOSSL="/home/$USER/auto-ssl/master/manual"


################################
### Runs the security script ###

# Deploy the SSH Keys and config files.
bash $AUTOSSL/security/security.sh
# Error catching.
if [ $? -eq 0 ]; then
	printf "${GREEN}SECURITY SCRIPT DONE$s\n$s\n${NC}"
else
	printf "${RED}$s\nSECURITY SCRIPT FAILED$s\n$s\n${NC}" >&2
fi


#######################################
### Runs the domain renewal scripts ###

# Checks for and creates domain log folder.
printf "${RED}$s\nRUNNING RENEW SCRIPTS$s\n$s\n${NC}"
for DOMAIN in $AUTOSSL/domains/*.sh
do
	# Cleans cerbot config files to avoid previous parameters.
	sudo rm -rvf /etc/letsencrypt/renewal/$DOMAIN.conf
	
	# Runs the domain renew script.
	bash $DOMAIN  
		
	# Error catching.
	if [ $? -eq 0 ]; then
	        printf "${GREEN}$s\nRENEW SCRIPTS DONE$s\n$s\n${NC}"
	else
       	printf "${RED}$s\nCERTBOT RENEW FAILED FOR $DOMAIN$s\n$s\n${NC}" >&2
	fi
done


######################
### Cleanup Script ###

# Cleans up SSH keys and config.
printf "${RED}$s\nRUNNING CLEANUP SCRIPT$s\n$s\n${NC}"
sudo bash $AUTOSSL/security/cleanup.sh
printf "${GREEN}$s\nCLEANUP SCRIPT DONE$s\n$s\n${NC}"


########################
### For Audit Script ###

printf "${GREEN}$s\nCONFIRMED SUCCESS RUN$s\n${NC}"
exit 0
