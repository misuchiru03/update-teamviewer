#!/bin/bash

# Clear the RPM DEB and OTHER variables
RPM=0
DEB=0
OTHER=0

# Set the user's home directory
USRHOME=`eval echo ~$USER`

# Find out if machine is deb rpm or any other based
# Distro Arch test
# Arch tests first
if [[ `uname -a | egrep "amd64|x86_64"` ]]; then
        # 64 bit, now we need the OS
        # testing for rpm
        /usr/bin/rpm -q -f /usr/bin/dpkg > /dev/null 2>&1
        if [ "$?" == "127" ]; then
                # RPM does not exist
                # Test for dpkg
                /usr/bin/dpkg --search /usr/bin/rpm > /dev/null 2>&1
                if [ "$?" == "127" ]; then
                        # DEB does not exist
                        # Setting as other 64-bit
                        OTHER=1
                        EXT='tar.xz'
                        ARCH='amd64'
                else
                        DEB=1
                        EXT='deb'
                        ARCH='amd64'
                fi
        else
                RPM=1
                EXT='rpm'
                ARCH='x86_64'
        fi
elif [[ `uname -a | egrep "i386|i686"` ]]; then
        # 32 bit, now we need the OS
        # testing for rpm
        /usr/bin/rpm -q -f /usr/bin/dpkg > /dev/null 2>&1
        if [ "$?" == "127" ]; then
                # RPM does not exist
                # Test for dpkg
                /usr/bin/dpkg --search /usr/bin/rpm > /dev/null 2>&1
                if [ "$?" == "127" ]; then
                        # DEB does not exist
                        # Setting as other 32 bit
                        OTHER=1
                        EXT='tar.xz'
                        ARCH='i386'
                else
                        DEB=1
                        EXT='deb'
                        ARCH='i386'
                fi
        else
                RPM=1
                EXT='rpm'
                ARCH='i686'
        fi
else
        # Probably ARM, testing for the OS
        # testing for rpm
        /usr/bin/rpm -q -f /usr/bin/dpkg > /dev/null 2>&1
        if [ "$?" == "127" ]; then
                # RPM does not exist
                # Test for dpkg
                /usr/bin/dpkg --search /usr/bin/rpm > /dev/null 2>&1
                if [ "$?" == "127" ]; then
                        # DEB does not exist
                        # Setting as other 64-bit
                        OTHER=1
                        EXT='tar.xz'
                        ARCH='armhf'
                else
                        DEB=1
                        EXT='deb'
                        ARCH='armhf'
                fi
        else
                RPM=1
                EXT='rpm'
                ARCH='armv7hl'
        fi
fi

# Remove comment for debugging to test variables
#echo -e "DEB=$DEB\nRPM=$RPM\nOTHER=$OTHER\nARCH=$ARCH\nEXT=$EXT" && exit

# Check the most up-to-date version from teamviewer.com and set variable
# Check ARM version
if [[ "$ARCH" == "arm" ]]; then
	NEWESTVERSION=$(curl -s https://www.teamviewer.com/en/download/linux/ | grep -14 $ARCH | head -n 1 | cut -dv -f2 | cut -d'<' -f1 | cut -d' ' -f1)
else
	NEWESTVERSION=$(curl -s https://www.teamviewer.com/en/download/linux/ | grep -8 "*\." | grep $EXT | head -n 1 | cut -dv -f2 | cut -d'<' -f1 | cut -d' ' -f1)
fi

# Check currently installed version and set variable
CURRENTVERSION=$(teamviewer -version | grep TeamViewer | awk '{ print $4 }')

echo -e "Current Version:\t$CURRENTVERSION"
echo -e "Newest Version: \t$NEWESTVERSION"

if [ "$CURRENTVERSION" \< "$NEWESTVERSION" ]; then
        echo "There is an updated version."
#       exit 0   ###This line is for debugging purposes
else
        echo "You already have the most updated version."
        exit 0
fi
echo ''

# Setting the Teamviewer Filename we will use to download and install
if [[ "$ARCH" =~ ^(arm) ]]
	TV_FILENAME="teamviewer-host.$ARCH.$EXT"
else
	TV_FILENAME="teamviewer_$ARCH.$EXT"
fi

wget $(curl -s https://www.teamviewer.com/en/download/linux/ | grep -8 "$NEWESTVERSION" | grep $TV_FILENAME | cut -d'"' -f4) -O $USRHOME/Downloads/$TV_FILENAME

# Install the package
if [ $EXT == 'deb' ]; then
        sudo apt install -y $USRHOME/Downloads/$TV_FILENAME
elif [ $EXT == 'rpm' ]; then
        sudo yum install -y $USRHOME/Downloads/$TV_FILENAME
	### Not tested yet.  If you test it, and it doesn't work, please give me some feedback with corrections
        ### if you have any.
else
	### Also not tested yet.  If you test it, and it doesn't work, please give me some feedback with corrections
        ### if you have any.
        sudo tar xvJf $USRHOME/Downloads/$TV_FILENAME -C /opt/
        sudo ln -s /opt/teamviewer/teamviewer /usr/bin/teamviewer
        sudo /opt/teamviewer/tv-setup checklibs
        if [[ -z `sudo /opt/teamviewer/tv-setup checklibs | grep "All dependencies seem to be satisfied!"` ]]; then
                echo "You must install the missing dependencies before you can run TeamViewer."
                exit
	fi
fi
sudo teamviewer --daemon enable
sudo teamviewer --daemon start

echo ''
echo "Teamviewer has been updated.  If you are still unable to open the GUI, try fixing any broken dependencies."
exit 0
