# autossl
Automated Let's Encrypt SSL cert provisioning and remote distribution in BASH. Supports DNS verified wildcard certififcates with certbot as the mitochondria.

Verified to work on Centos 8 and Let's Encrypt certbot version 1.3.0 with DNSimple's DNS API. This script is compatible with all supported certbot domain API (AWS, DO, etc) options with minor adjustments.



#####################
### Installation ####
#####################



1. Copy repo to /home/$USER/. or symlink from this folder to your destination folder.

2. Create an unencrypted .TAR file with the root folder "keys" (example: ssh-keys.tar expands into a folder called ./keys) for your SSH keys and "config" file, then place under ~/auto-ssl/master/security/. Encryption/decryption with gpg2 is present, though only for advanced users. Edit the ~/auto-ssl/master/security/{security.sh; cleanup.sh} script variables to suit your conditions.

4. Create your preffered DNS providers API access token according to your domain provider and certbot's requirements (https://certbot.eff.org/docs/using.html?highlight=dns). Place this token under the ~/auto-ssl/master/domains/. folder and modify the example script to suit your domain provider.

5. Provision the domains you'll be renewing using the same example fscript under ~/auto-ssl/master/domains/. Do the same using the ~/auto-ssl/master/manual/domains-list/. manual intervention example script.

5. Create cron job to run on your schedule by running the ~/auto-ssl/master/master.sh script

Done.



#####################################
##### AUTO-SSL PROGRAM OVERVIEW #####
#####################################




# This script is triggered by a cron job every 58 days. This job is manually set by the user.
# If it fails then the AUDIT.SH script prints a message visible to all who log on to the server.
# If 60 days have passed since last renewal Letsencrypt sends and email to the email registered with Let's Encrypt at setup.




##########################################################################
### IF YOU NEED TO RUN THIS MANUALLY, GOT TO THE ./MANUAL/MASTER.SH !! ###
##########################################################################



### General Overview of Mechanics ###

# 1. MASTER.SH is activated and creates logging parameters.

# 2. MASTER.SH backs up "/home/$USER/auto-ssl/master" folder to "/home/$USER/ssl-backup" folder.

# 3. MASTER.SH script triggers ./security/SECURITY.SH that deploys SSH keys and config.

# 4. MASTER.SH checks integrity of AUTO-SSL folder structures.

# 5. MASTER.SH script triggers LOOP for ./domains/$DOMAIN.SH script for each domain configured in ./deploy/ folder.

        # 6. $DOMAIN.SH runs certbot renew for only that domain.

        # 7. $DOMAIN.SH breaks the chain for $DEPLOY if SSL renewal fails, only for this domain; and calls the AUDIT.SH script to log and warn..

        # 8. $DOMAIN.SH script triggers $DEPLOY.SH script to install on other relevant servers.

                # 9. $DEPLOY.SH cleans preconfigured $SERVER AUTO-SSL staging folder to insure success.

                # 10. $DEPLOY.SH rsyncs $DOMAIN SSL folder and certs to staging folder.

                # 11. $DEPLOY.SH installs SSL to Letsencrypt folder on $SERVER and cleans staging folder of secrets.

# 12. MASTER.SH triggers ./security/CLEANUP.SH that insures no SSH keys are laying around.

# 13. MASTER.SH terminates.


