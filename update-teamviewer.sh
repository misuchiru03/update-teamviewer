#!/bin/bash

# Clear the RPM and DEB variables
RPM=0
DEB=0

# Set the user's home directory
USRHOME=`eval echo ~$USER`

# Find out if machine is deb or rpm based
# DEB test
/usr/bin/dpkg --search /usr/bin/rpm > /dev/null 2>&1
if [ "$?" == "127" ]; then
        #dpkg does not exist
        DEB=0
else
        DEB=1
	# Take this time to set the arch
	if [ `uname -i` == 'x86_64' ]; then
		EXT='deb'
		ARCH='amd64'
	else
		EXT='deb'
		ARCH='i386'
	fi
fi

# RPM test
/usr/bin/rpm -q -f /usr/bin/dpkg > /dev/null 2>&1
if [ "$?" == "127" ]; then
        #rpm doesn't exist
        RPM=0
else
        RPM=1
	# Take this time to set the arch
	if [ `uname -i` = 'x86_64' ];then
		EXT='rpm'
		ARCH='x86_64'
	else
		EXT='rpm'
		ARCH='i686'
	fi	
fi

# Check the most up-to-date version from teamviewer.com and set variable
NEWESTVERSION=$(curl -s https://www.teamviewer.com/en/download/linux/ | grep -8 "*\." | grep $EXT | head -n 1 | cut -dv -f2 | cut -d'<' -f1 | cut -d' ' -f1)

# Check currently installed version and set variable
CURRENTVERSION=$(teamviewer -version | grep TeamViewer | awk '{ print $4 }')

echo -e "Current Version:\t$CURRENTVERSION"
echo -e "Newest Version: \t$NEWESTVERSION"

if [ "$CURRENTVERSION" \< "$NEWESTVERSION" ]; then
        echo "There is an updated version."
#	exit 0   ###This line is for debugging purposes
else
        echo "You already have the most updated version."
        exit 0
fi
echo ''

# Setting the Teamviewer Filename we will use to download and install
TV_FILENAME="teamviewer_$NEWESTVERSION_$ARCH.$EXT"

wget $(curl -s https://www.teamviewer.com/en/download/linux/ | grep -8 $NEWESTVERSION | grep linkBlue | grep $ARCH\.$EXT | cut -d'"' -f4) -O $USRHOME/Downloads/$TV_FILENAME

# Install the package
if [ $EXT == 'deb' ]; then
	sudo dpkg -i $USRHOME/Downloads/$TV_FILENAME
else
	sudo yum install -y $USRHOME/Downloads/$TV_FILENAME ### Not tested yet.  If you test it, and it doesn't work, please give me some feedback with corrections if you have it.
fi
sudo teamviewer --daemon enable
sudo systemctl start teamviewerd

echo ''
echo "Teamviewer has been updated.  If you are still unable to open the GUI, try fixing any broken dependencies."
