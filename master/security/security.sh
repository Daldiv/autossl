#!/bin/bash


##################################
##### SSH Key Acccess Script #####
##################################


#################
### Variables ###

# TAR files..
TARG="git.tar"
TAR="em.tar"

# Console output colors.
RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m'

# Auto-ssl folder path.
AUTOSSL="/home/entermedia/auto-ssl/master/security"

# SSH folder
SSH=/home/entermedia/.ssh

# Time stamp.
NOW=$(date +"%m-%d-%Y")

# Logging function.
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$AUTOSSL/master/logs/security/$NOW-SECURITY.log 2>&1


###############
### Cleanup ###

### NEEDS GNUPG-2.20 ###

# Shreds pre-existing $TARG files if any leftover. 
#if [ -f $TARG ]; then
#    shred -vfuz $TARG
#fi

# Creates keys folder if not present.

# Creates keys folder if not present.
if [ ! -d $SSH/auto-ssl/ ]; then
        mkdir -v $SSH/auto-ssl
        chmod -v 700 $SSH/auto-ssl/
fi


if [ ! -d $SSH/auto-ssl/keys/ ]; then
	mkdir -v $SSH/auto-ssl/keys/
	chmod -v 700 $SSH/auto-ssl/keys
	printf "${GREEN}$s\nCreated Keys Folder$s\n${NC}"
fi


###############
### Git Key ###

### NEEDS GNUPG-2.20 ###

# Decrypts and extracts TAR files.
#read $P < <(gpg --batch --pinentry-mode loopback --passphrase-file ./.g -o - -d ./..g/.g)
#gpg --batch --pinentry-mode=loopback --passphrase $P -o $TARG --decrypt $TARG.gpg
#P=">/dev/null" || -H break
#tar -xf $TARG
#printf "${GREEN}$s\nGit Key Extracted$s\n$s\n${NC}"

# Configures the config file for SSH.
#printf "${RED}Checking GIT Config$s\n${NC}"
#if grep -Fq "Host m38.git.test" $SSH/config
#then
        # code if found.
#        printf "${RED}GIT CONFIG NOT SET$s\n${NC}"
#else
        # Configures SSH config file.
#        printf "$s\nHost m38.git$s\nHostname mediadb38.entermediadb.net$s\nUser git$s\nIdentityFile ~/.ssh/keys/gitem.pk$s\n" >> $SSH/config
        
        # Copies the key to SSH folder and sets permissions.
#        printf "${RED}Copying Key$s\n${NC}"
#	cp -v ./gitem.pk $SSH/keys
#        chmod 600 $SSH/keys/gitem.pk
#        printf "${GREEN}SSH GIT Config Set$s\n$s\n${NC}"
#fi

# Get $TAR from m38.
#printf "${RED}Aqcuiring TAR$s/n$s/n${NC}"
#rsync -azPi m38.git:/home/git/rsync/emssh.tar.gpg . || -H break
#printf "${GREEN}Acquired TAR$s\n$s\n${NC}"


################################
### TAR decryption with GPG2 ###

# Decrypts TAR.
#printf "${RED}$s\nDecrypting TAR$s\n$s\n${NC}"
#read $P < <(gpg --batch --pinentry-mode loopback --passphrase-file ./.g -o - -d ./..g/.g)
#gpg --batch --pinentry-mode=loopback --passphrase $P -o $TAR --decrypt $TAR.gpg || -H break
#P=">/dev/null"

# Extracts and cleans up afterwards.
printf "${RED}Extracting Keys$s\n${NC}"
tar -vxf $AUTOSSL/$TAR -C $AUTOSSL 

# Error catching.
if [ $? -eq 0 ]; then
        printf "${GREEN}Keys Extracted$s\n$s\n${NC}"
else
        printf "${RED}$s\nTAR EXTRACTION FAILED$s\n$s\n${NC}" >&2
	FAIL="TAR EXTRACTION FAILED"
	ERRORPOINT="SECURITY.SH script"
	bash /home/entermedia/auto-ssl/master/audit.sh "$FAIL" "$ERRORPOINT"
fi
#shred -vfuz $TAR

# Copies files and sets permissions.
printf "${RED}$s\nCopying Keys$s\n${NC}"
cp -vf $AUTOSSL/keys/* $SSH/auto-ssl/keys
printf "${RED}$s\nSetting Permissions$s\n${NC}"
chmod -v 700 $SSH/auto-ssl/keys
chmod -v 600 $SSH/auto-ssl/keys/*

# Error catching.
if [ $? -eq 0 ]; then
        printf "${GREEN}SSH Keys Configured$s\n$s\n${NC}"
else
        printf "${RED}$s\nSSH CONFIGURATION FAILED$s\n$s\n${NC}" >&2
        FAIL="SSH CONFIGURATION FAILED"
        ERRORPOINT="SECURITY.SH script"
        bash /home/entermedia/auto-ssl/master/audit.sh "$FAIL" "$ERRORPOINT"
fi

# Cleans up residue files.
printf "${RED}$s\nCleaning$s\n${NC}"
shred -fuz $AUTOSSL/keys/*
shred -fuz $AUTOSSL/*.pk
rm -rvf $AUTOSSL/keys

# Checks and configures SSH config file.
if grep -Fq "Include ~/.ssh/auto-ssl/keys/entermedia.conf" $SSH/config
then
        printf "${GREEN}SSH CONFIG OK$s\n${NC}"
else
     #   # Configures SSH config.
        echo "Include ~/.ssh/auto-ssl/keys/entermedia.conf 
	
	$(cat ~/.ssh/config)" > $SSH/config
	printf "${GREEN}SSH CONFIG SET$s\n${NC}"
fi

#cd ..
printf "${GREEN}$s\nKeys Extracted Successfully$s\n $s\n${NC}"

exit 0
