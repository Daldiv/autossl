#!/bin/bash


#################################################
##### DOMAIN SCRIPT TO RENEW AND DEPLOY SSL #####
#################################################


#################
### Variables ###

# Set domain to work on.
DOMAIN="test.com"

# Server list to work on.
declare -a SERVERS=("server1", "server2", "server3")

# Console output colors.
RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m'

# Time stamp.
NOW=$(date +"%m-%d-%Y")

# Letsencrypt oath.
LETS="/etc/letsencrypt/live"

# Auto-ssl path
AUTOSSL="/home/$USER/auto-ssl/master"

# Logging function.
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1> /home/$USER/auto-ssl/master/logs/domains/$DOMAIN/$NOW-RENEW.log 2>&1


#####################
### Certbot Renew ###

# Cleans Letsencrypt folder to avoid versions.
#printf "${RED}$s\nCleaning $DOMAIN Certbot Folders$s\n${NC}"
#sudo shred -vfuz $LETS/live/$DOMAIN/* && sudo shred -vfuz $LETS/archive/$DOMAIN/*
#sudo rm -rvf $LETS/live/$DOMAIN && sudo rm -rvf $LETS/archive/$DOMAIN
#sudo certbot delete -nv --logs-dir $AUTOSSL/logs/letsencrypt --cert-name $DOMAIN
#printf "${GREEN}$DOMAIN Certbot Folders Cleaned$s\n$s\n${NC}"

# Runs certbot renew.
#printf "${RED}$s\nRunning Certbot Renew$s\n$s\n${NC}"
#sudo certbot certonly --dry-run --force-renewal --logs-dir $AUTOSSL/logs/letsencrypt -nv \
#--dns-dnsimple \
#--dns-dnsimple-credentials ./dnsimple.ini \
#--dns-dnsimple-propagation-seconds 90 \
#-d *.$DOMAIN --cert-name $DOMAIN 

# Error catching.
if [ $? -eq 0 ]; then
	printf "${GREEN}$s\nCertbot Renew Successful$s\n$s\n${NC}"
else
	printf "${RED}$s\nCertbot Renew FAILED$s\n$s\n${NC}" >&2
	FAIL="CERTBOT RENEW FAILED FOR $DOMAIN"
	bash $AUTOSSL/audit.sh "$FAIL"
	exit 1
fi

##################
### Deploy SSL ###

# Runs Deploy script and passes $DOMAIN variable.
printf "${RED}$s\nRunning Deployment Script$s\n$s\n${NC}"
. $AUTOSSL/manual/scripts/deploy.sh "$DOMAIN" "SERVERS[@]"
printf "${GREEN}$s\nDeployment Script Done$s\n$s\n${NC}"

exit 0
