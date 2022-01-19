#!/bin/bash

# Script to automagically update Plex Media Server on Synology NAS
#
# Must be run as root.
#
# @author @martinorob https://github.com/martinorob
# https://github.com/martinorob/plexupdate/

# Location of temp folder for this script
tmpFolder="/tmp/plex"
resultFile=$tmpFolder/result.txt

# Make temp directory if it doesn't already exist
mkdir -p $tmpFolder/ > /dev/null 2>&1

function updatePlex() {
  # Get information we need
  echo "Checking for Plex updates..."
  jq=$(curl -s https://plex.tv/api/downloads/5.json)
  plexPackageName=$(synopkg list | grep Plex | cut -d'-' -f1)

  # Get version numbers
  # For some reason the part after the dash changes, so exclude it
  newVersion=$(echo ${jq} | jq -r '.nas."Synology (DSM 7)".version' | cut -d'-' -f1)
  curVersion=$(synopkg version "$plexPackageName")
  echo "Latest Version:    $newVersion"
  echo "Installed Version: $curVersion"

  # Compare version numbers
  dpkg --compare-versions "$newVersion" "gt" "$curVersion"
  if [ $? -eq "0" ]; then
    echo "New version available! Updating now..."
    synonotify PKGHasUpgrade '{"%PKG_HAS_UPDATE%": "Plex Media Server"}'
    CPU=$(uname -m)
    url=$(echo "${jq}" | jq -r '.nas."Synology (DSM 7)".releases[] | select(.build=="linux-'"${CPU}"'") | .url')
    
    # Download the update
    wget $url -P $tmpFolder/
    filename=$(basename $url)
    
    # Install the update
    synopkg install $tmpFolder/$filename
    sleep 30
    
    # Start Plex and cleanup
    synopkg start "$plexPackageName"
    rm -rf $tmpFolder/*.spk
  else
    echo "No new version available."
  fi
}

updatePlex |& tee $resultFile
exit
