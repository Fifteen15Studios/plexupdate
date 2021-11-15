#!/bin/bash

# Script to automagically update Plex Media Server on Synology NAS
#
# Must be run as root.
#
# @author @martinorob https://github.com/martinorob
# https://github.com/martinorob/plexupdate/

# Volume where Plex is installed
VOLUME=$(echo "/volume1")
# Location of temp folder for this script
tmpFolder="/tmp/plex"
resultFile=$tmpFolder/result.txt

# Make temp directory if it doesn't already exist
mkdir -p $tmpFolder/ > /dev/null 2>&1

# Get information we need
token=$(cat ${VOLUME}/PlexMediaServer/AppData/Plex\ Media\ Server/Preferences.xml | grep -oP 'PlexOnlineToken="\K[^"]+')
url=$(echo "https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=$token")
jq=$(curl -s ${url})

# Get version numbers
# For some reason the part after the dash changes, so exclude it
newversion=$(echo ${jq} | jq -r '.nas."Synology (DSM 7)".version' | cut -d'-' -f 1)
echo "New Ver: $newversion" > $resultFile
curversion=$(synopkg version "PlexMediaServer" | cut -d'-' -f 1)
echo "Cur Ver: $curversion" >> $resultFile

# Compare version numbers
if [ "$newversion" != "$curversion" ]
# New Version Available
then
	/usr/syno/bin/synonotify PKGHasUpgrade '{"%PKG_HAS_UPDATE%": "Plex Media Server"}'
	CPU=$(uname -m)
	url=$(echo "${jq}" | jq -r '.nas."Synology (DSM 7)".releases[] | select(.build=="linux-'"${CPU}"'") | .url')
	# Download the file
	/bin/wget $url -P $tmpFolder/
	# Get filename from URL
	slashes=$(awk -F"/" '{print NF-1}' <<< "${url}")
	filename=$(echo $url | cut -d '/' -f $(expr $slashes + 1))
	# Install the file
	/usr/syno/bin/synopkg install $tmpFolder/$filename >> $resultFile
	sleep 30
	/usr/syno/bin/synopkg start "Plex Media Server"
	rm -rf $tmpFolder/*.spk
else
	echo "No new version available" >> $resultFile
fi
exit
