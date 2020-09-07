#!bin/bash


##################################
##### Cleanup Secrets Script #####
##################################


###################################
### Removes SSH keys and config ###

# Time stamp.
NOW=$(date +"%m-%d-%Y")

# Auto-ssl folder path.
AUTOSSL=/home/$USER/auto-ssl

# Logging function.
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$AUTOSSL/master/logs/security/$NOW-CLEANUP.log 2>&1

# Safely removes secrets in SSH.
shred -fuz /home/$USER/.ssh/auto-ssl/keys/*
rm -vrf /home/$USER/.ssh/auto-ssl
#shred -vfuz *.tar
shred -fuz *.pk


exit 0
