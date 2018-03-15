# update-teamviewer.sh
A script that helps automate the updating of TeamViewer.
No options, no garbage.  Uses system queries to determine the arch and install version (deb/rpm) it should automatically download and install.  Can be used as a cronjob or manual updates.

General Linux Dependencies
The following packages are required to be able to properly install/run Teamviewer: (individual distro names may vary)
        libQt5Core.so.5 => not found
        libQt5DBus.so.5 => not found
        libQt5Gui.so.5 => not found
        libQt5Network.so.5 => not found
        libQt5Qml.so.5 => not found
        libQt5Quick.so.5 => not found
        libQt5WebKit.so.5 => not found
        libQt5WebKitWidgets.so.5 => not found
        libQt5Widgets.so.5 => not found
        libQt5X11Extras.so.5 => not found

Void-Linux package names:
        qt5
        qt5-webkit
        qt5-x11extras
