#!/bin/sh
#
# This is a default logout script used as a launchpad for startup scripts

### Properties ###
# Basic default variables used in providing launchpad functionality

# This var stores the file path of the main login script.
# This is determined by parsing for the specified LoginHook
scriptPath="$(defaults read com.apple.loginwindow LogoutHook)"
scriptPath=${scriptPath%/logoutScript.sh}
#



#_____________________### Script Source Code ####________________________

# Variables #############################################################
#																		#
# Use this area to store variables needed to run external scripts below #
#																		#
#																		#
#																		#
#########################################################################


# External Scripts #

# Examples :
# $scriptPath/externalScript.sh #  // Run as root
# /usr/bin/su $1 $scriptPath/externalScript.sh #  // Run as logged-in user
#
#

exit 0
