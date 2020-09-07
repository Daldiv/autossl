#!/bin/bash


#################################################
##### DOMAIN SCRIPT TO RENEW AND DEPLOY SSL #####
#################################################


#################
### Variables ###

# Set domain to work on.
DOMAIN="domain-to-renew.com"
 
# Server list to work on.
declare -a SERVERS=("server1", "server2", "server3")

# Console output colors.
RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m'

# Time stamp.
NOW=$(date +"%m-%d-%Y")

# Letsencrypt oath.
LETS="/etc/letsencrypt"

# Auto-ssl path
AUTOSSL="/home/$USER/auto-ssl/master"


#####################
### Certbot Renew ###

# Cleans Letsencrypt folder to avoid versions.
printf "${RED}$s\nCleaning $DOMAIN Certbot Folders$s\n${NC}"
sudo shred -vfuz $LETS/live/$DOMAIN/* && sudo shred -vfuz $LETS/archive/$DOMAIN/*
sudo rm -rvf $LETS/live/$DOMAIN && sudo rm -rvf $LETS/archive/$DOMAIN
sudo certbot delete -nv --logs-dir $AUTOSSL/logs/letsencrypt --cert-name $DOMAIN
printf "${GREEN}$DOMAIN Certbot Folders Cleaned$s\n$s\n${NC}"

# Runs certbot renew.
printf "${RED}$s\nRunning Certbot Renew For $DOMAIN $s\n$s\n${NC}"
sudo certbot certonly --force-renewal --logs-dir $AUTOSSL/logs/letsencrypt -nv \
--dns-dnsimple \
--dns-dnsimple-credentials $AUTOSSL/domains/dnsimple.ini \
--dns-dnsimple-propagation-seconds 90 \
-d *.$DOMAIN -d $DOMAIN --cert-name $DOMAIN 

# Error catching.
if [ $? -eq 0 ]; then
	printf "${GREEN}$s\nCertbot Renew Successful For $DOMAIN $s\n$s\n${NC}"
else
	printf "${RED}$s\nCertbot Renew FAILED For $DOMAIN $s\n$s\n${NC}" >&2
	FAIL="CERTBOT RENEW FAILED FOR $DOMAIN FAILED"
	ERRORPOINT="$DOMAIN.SH script"
	bash $AUTOSSL/audit.sh "$FAIL" "$ERRORPOINT"
	exit 1
fi

##################
### Deploy SSL ###

# Runs Deploy script and passes $DOMAIN variable.
printf "${RED}$s\nRunning Deployment Script For $DOMAIN $s\n$s\n${NC}"
. $AUTOSSL/domains/deploy/deploy.sh "$DOMAIN" "SERVERS[@]"
printf "${GREEN}$s\nDeployment Script Done For $DOMAIN $s\n$s\n${NC}"

exit 0
