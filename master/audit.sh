#!/bin/bash


####################################
##### Independant Audit Script #####
####################################

# Receives variable from failure point.
EPICFAIL="$1"
ERRORPOINT="$2"

# Auto-ssl path.
AUTOSSL="/home/$USER/auto-ssl/master"

# Time stamp.
NOW=$(date +"%m-%d-%Y")


###############
### Logging ###

# Checks for audit logs folder.
if [ ! -d $AUTOSSL/logs/audit ]; then
        sudo mkdir -v $AUTOSSL/logs/audit
fi

# Logging function.
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1> $AUTOSSL/logs/audit/$NOW-AUDIT.log 2>&1


########################
### Warning Messages ###

# Posts message to all logged in users.
wall "WARNING, AUTO-SSL HAS EXPERIENCED AN ERROR: $EPICFAIL \ 
 Check $AUTOSSL/logs/{audit,$ERRORPOINT}"

# Posts message on login and auto-ssl root folder.
touch $AUTOSSL/motd
echo "$NOW: WARNING, AUTO-SSL HAS EXPERIENCED AN ERROR: $EPICFAIL" >> $AUTOSSL/motd
echo "Check $AUTOSSL/logs/{./audit, ./domains/$ERRORPOINT}" >> $AUTOSSL/motd
echo "To remove this message first FIX, then delete /etc/motd file" >> $AUTOSSL/motd
cp -vf $AUTOSSL/motd $AUTOSSL/AUTO-SSL-ERROR.message
sudo mv -vf $AUTOSSL/motd /etc/motd

# Checks Certbot certs.
touch $AUTOSSL/logs/audit/$NOW-CERT-STATUS.log
sudo certbot certificates >> $AUTOSSL/logs/audit/$NOW-CERT-STATUS.log

exit 0
