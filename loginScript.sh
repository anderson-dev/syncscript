#!/bin/sh
#
# This is a default login script used as a launchpad for startup scripts

### Properties ###
# Basic default variables used in providing launchpad functionality

# This var stores the file path of the main login script.
# This is determined by parsing for the specified LoginHook
scriptPath="$(defaults read com.apple.loginwindow LoginHook)"
scriptPath=${scriptPath%/loginScript.sh}
#



#_____________________### Script Source Code ####________________________

# Variables #############################################################
#																		#
# Use this area to store variables needed to run external scripts below #
#																		#
#																		#
#																		#
#########################################################################
echo "loginScript is running" > /tmp/testing.tmp

# External Scripts #

# Examples :
# $scriptPath/externalScript.sh #  // Run as root
# /usr/bin/su $1 $scriptPath/externalScript.sh #  // Run as logged-in user

# Start Home Folder Sync Setup Module
/usr/bin/su $1 $scriptPath/syncSetup.sh
# End

exit 0
