#!/bin/bash
# This script is used to change the transmission uid/gid to match a user on the host docker machine so volume perms are correct

if [[ "$UID" != "0" ]]; then
    echo "Can only be run as root."
    exit 1
fi

if [[ ! "$TRANSMISSION_UID" || ! "$TRANSMISSION_GID" ]]; then
    echo "ERROR: Missing required environment variables TRANSMISSION_UID and TRANSMISSION_GID"
    exit 1
fi

CURRENT_TRANSMISSION_UID=$(getent passwd "transmission" | cut -d: -f3)
CURRENT_TRANSMISSION_GID=$(getent passwd "transmission" | cut -d: -f4)

echo "Preferred transmission UID ($TRANSMISSION_UID) current UID ($CURRENT_TRANSMISSION_UID)"
echo "Preferred transmission GID ($TRANSMISSION_GID) current GID ($CURRENT_TRANSMISSION_GID)"
if [[ "$TRANSMISSION_UID" == "$CURRENT_TRANSMISSION_UID" && "$TRANSMISSION_GID" == "$CURRENT_TRANSMISSION_GID" ]]; then
    echo "No UID/GID changes needed."
    exit 0
fi

# Check to make sure UID/GID we want to change to are free
EXISTING_UID=$(getent passwd $TRANSMISSION_UID | cut -d: -f1)
EXISTING_GID=$(getent group $TRANSMISSION_GID | cut -d: -f1)

if [[ "$EXISTING_UID" || "$EXISTING_GID" ]]; then
    echo "Desired UID $TRANSMISSION_UID already taken by '$EXISTING_UID'"
    echo "Desired UID $TRANSMISSION_GID already taken by '$EXISTING_GID'"
    echo "ERROR: Cannot change UID/GID."
    exit 1
fi

echo "Changing UID/GID! Preferred transmission UID/GID do not match current."
# https://muffinresearch.co.uk/linux-changing-uids-and-gids-for-user/
usermod -u $TRANSMISSION_UID transmission
groupmod -g $TRANSMISSION_GID transmission
# Limit to the couple directories we should need to change
for DIR in /home /var/log; do
    find $DIR -user $CURRENT_TRANSMISSION_UID -exec chown --no-dereference $TRANSMISSION_UID {} \;
    find $DIR -group $CURRENT_TRANSMISSION_GID -exec chgrp --no-dereference $TRANSMISSION_GID {} \;
done
# Fix our download directories, but down go changing all the perms
# as that is likely not needed
for DIR in /mnt/Downloads_In_Progress /mnt/Downloads_Completed; do
    chown --no-dereference $TRANSMISSION_UID $DIR
    chgrp --no-dereference $TRANSMISSION_GID $DIR 
done
usermod -g $TRANSMISSION_GID transmission
echo "Done!"
