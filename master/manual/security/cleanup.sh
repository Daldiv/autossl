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

# Safely removes secrets in SSH.
shred -vfuz /home/$USER/.ssh/auto-ssl/keys/*
rm -vrf /home/$USER/.ssh/auto-ssl
#shred -vfuz *.tar
shred -vfuz *.pk

exit 0
