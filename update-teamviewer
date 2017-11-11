#!/bin/bash

# Clear the RPM and DEB variables
RPM=0
DEB=0

# Find out if machine is deb or rpm based
# DEB test
/usr/bin/dpkg --search /usr/bin/rpm > /dev/null 2>&1
if [ "$?" == "127" ]; then
	#dpkg does not exist
	DEB=0
else
	DEB=1
fi

# RPM test
/usr/bin/rpm -q -f /usr/bin/dpkg > /dev/null 2>&1
if [ "$?" == "127" ]; then
	#rpm doesn't exist
	RPM=0
else
	RPM=1
fi

if [ "$DEB" == "1" ]; then
	TYPE="i386.deb"
else
	TYPE="i686.rpm"
fi

# Check the most up-to-date version from teamviewer.com and set variable
NEWESTVERSION=$(curl -s https://www.teamviewer.com/en/download/linux/ | grep -1 teamviewer_$TYPE | head -n 4 | grep DownloadVersion | cut -d'>' -f2- | cut -d' ' -f-1 | cut -d'v' -f2-)

# Check currently installed version and set variable
CURRENTVERSION=$(teamviewer -version | grep TeamViewer | awk '{ print $4 }')

echo -e "Current Version:\t$CURRENTVERSION"
echo -e "Newest Version: \t$NEWESTVERSION"

if [ "$CURRENTVERSION" \< "$NEWESTVERSION" ]; then
	echo "There is an updated version."
else
	echo "You already have the most updated version."
	exit 0
fi
echo ''
TV_FILENAME="teamviewer_$NEWESTVERSION\_$TYPE"
wget $(curl -s https://www.teamviewer.com/en/download/linux/ | grep -e teamviewer.$TYPE | awk -F'"' '{ print $2 }') -O ~/Downloads/$TV_FILENAME
sudo dpkg -i ~/Downloads/$TV_FILENAME
