# autossl
Automated Let's Encrypt SSL cert provisioning and remote distribution in BASH. Supports DNS verified wildcard certififcates with certbot as the mitochondria.

Verified to work on Centos 8 and Let's Encrypt certbot version 1.3.0 with DNSimple's DNS API. This script is compatible with all supported certbot domain API (AWS, DO, etc) options with minor adjustments. Further details are in the varying folder's README files.



#####################
### Installation ####
#####################



1. Copy repo to /home/$USER/. or symlink from this folder to your destination folder.

2. Create an unencrypted .TAR file with the root folder "keys" (example: ssh-keys.tar expands into a folder called ./keys) for your SSH keys and "config" file, then place under ~/auto-ssl/master/security/. Encryption/decryption with gpg2 is present, though only for advanced users. Edit the ~/auto-ssl/master/security/{security.sh; cleanup.sh} script variables to suit your conditions.

4. Create your preffered DNS providers API access token according to your domain provider and certbot's requirements (https://certbot.eff.org/docs/using.html?highlight=dns). Place this token under the ~/auto-ssl/master/domains/ folder and modify the example script to suit your domain provider.

5. Provision the domains you'll be renewing using the same example fscript under ~/auto-ssl/master/domains/. Do the same using the ~/auto-ssl/master/manual/domains-list/ manual intervention example script.

5. Create cron job to run on your schedule by running the ~/auto-ssl/master/master.sh script.

Cheers.




