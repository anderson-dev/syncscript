#!/bin/sh

# This script completes a setup to synchronize a user's home folder with a remote location.

### Properties ###

# A file synchronization tool is required
syncToolCmd="unison"
pathToSyncTool="/usr/local/bin"
pathToSyncTool=${pathToSyncTool%/} #prevent trailing slash

# File Server's Fully Qualified Host Name (i.e. myserver.mydomain.edu)
# [or the IP address] and port
fileServer="adserverroot.home.ad"
fileServerOS="Windows"
port=874

# Remote machine's local path to User's Home Folder
# ... specified using cross-platform forward slashes { "c:/temp" = "c:\temp" }
case "$fileServerOS" in
	'Windows')
	remoteHome="u:/Users/$USER"
	;;
	'CGYWIN')
	remoteHome="/cygdrive/u/Users/$USER"
	;;
	*)
	remoteHome="/Users/$USER"
	;;
esac

remoteHome=${remoteHome%/} #prevent trailing slash


# Relative paths to Remote Machine folder locations
# *** DO NOT PUT A '/' AT THE BEGINNING OR END - THEY WILL BE (PRE/A)PENDED AUTOMATICALLY
remoteDocumentsFolder="My Documents"
remoteDownloadsFolder="Downloads"
remoteMusicFolder="My Documents/My Music"
remotePicturesFolder="My Documents/My Pictures"
remoteMoviesFolder="My Documents/My Videos"
remoteSiteFolder="Sites"

# Ignore these filenames
ignoreFiles[0]="temp.*"
ignoreFiles[1]="*.tmp"
ignoreFiles[2]="*.o"
ignoreFiles[4]=".DS_Store"
ignoreFiles[5]=".localized"
ignoreFiles[6]=".FBCIndex"
ignoreFiles[7]=".FBCLockFolder"
ignoreFiles[8]=".CFUserTextEncoding"
ignoreFiles[9]=".bash_history"
ignoreFiles[10]=".viminfo"
ignoreFiles[11]=".lesshst"
ignoreFiles[12]=".parallels*"
ignoreFiles[13]="unison.log"

ignoreFiles[20]="?Home?.app"
ignoreFiles[21]="?Desktop?.app"
ignoreFiles[22]="?Documents?.app"
ignoreFiles[23]="?Downloads?.app"
ignoreFiles[24]="?Movies?.app"
ignoreFiles[25]="?Music?.app"
ignoreFiles[26]="?Pictures?.app"
ignoreFiles[27]="?Command?.app"
ignoreFiles[28]="?General?.app"
ignoreFiles[29]="?Public?.app"
ignoreFiles[30]="?Information?.app"
ignoreFiles[31]="?Mail?.app"
ignoreFiles[32]="?normal?.app"
ignoreFiles[33]="?Mail?.app"
ignoreFiles[34]="?ToDo?.app"
ignoreFiles[35]="?Utilities?.app"
ignoreFiles[36]="?PC?.app"
ignoreFiles[37]="?Account?.app"
ignoreFiles[38]="Microsoft?Windows?XP"
ignoreFiles[39]="Stack?Icons"

ignoreFiles[50]="*.lnk"
ignoreFiles[51]="desktop.ini"
ignoreFiles[52]="Thumbs.db"

#ignore = Name {.VolumeIcon.icns,.HSicon,Temporary*,.Temporary*,TheFindByContentFolder}
#        ignore = Name {TheVolumeSettingsFolder,.Metadata,.filler,.idsff,.CFUserTextEncoding}

# Ignore these file paths
ignorePaths[0]=".Spotlight-V100"
ignorePaths[1]=".TemporaryItems"
ignorePaths[2]=".Trash"
ignorePaths[3]="Cache*"
ignorePaths[4]=".ssh"
ignorePaths[5]=".unison"

ignorePaths[10]="RECYCLER"

#---------------------------### Script Source Code ###---------------------------------#

# Function used to abstract the building of a 'unison' profile
# Example:  buildProfile fileName root1 root2
# (where root1 and root2 and the root directory pairs used in synchronization)
function buildProfile() {
	#vars
	fileName=$1
	root1=$2
	root2=$3
	
	if echo $fileName | grep -q common; then
		includeFile=${fileName%.prf}
	fi
	
	#processing
	if echo $fileName | grep -q common; then
				
		echo "# Options:" >> $includeFile
		echo "batch = true" >> $includeFile
		echo "rsrc = false" >> $includeFile
		echo "follow = Path iChat Icons" >> $includeFile
		echo "" >> $includeFile
		
		echo "# File names to ignore:" >> $includeFile
		for entry in ${ignoreFiles[@]}; do
			echo "ignore = Name $entry" >> $includeFile
		done
		echo "" >> $includeFile
		
		echo "# File paths to ignore" >> $includeFile
		for entry in ${ignorePaths[@]}; do
			echo "ignore = Path $entry" >> $includeFile
		done
		echo "" >> $includeFile
	else
		if [ ! -z $includeFile ]; then
			echo "# Include contents of '$includeFile'" >> $fileName
			echo "include $includeFile" >> $fileName
			echo "" >> $fileName
		fi
		echo "# Roots of the synchronization" >> $fileName
		echo "root = $root1" >> $fileName
		echo "root = socket://$fileServer:$port/$root2" >> $fileName
		echo "" >> $fileName
	fi
	
	if echo $fileName | grep -q root; then
		echo "" >> $fileName
		echo "# Exclude these paths from root sync" >> $fileName
		echo "ignore = Path Documents" >> $fileName
		echo "ignore = Path My?Documents" >> $fileName
		echo "ignore = Path Movies" >> $fileName
		echo "ignore = Path Music" >> $fileName
		echo "ignore = Path Pictures" >> $fileName
		echo "ignore = Path Favorites" >> $fileName #exclude incompatible '.url' files
		echo "ignore = Path Library" >> $fileName
		echo "" >> $fileName
	fi
	
	if echo $fileName | grep -q docs; then
		echo "" >> $fileName
		echo "# Prevent content duplication of 'Music', 'Pictures', and 'Movies' Folders" >> $fileName
		echo "ignore = Path ${remoteMoviesFolder#$remoteDocumentsFolder/}" >> $fileName
		echo "ignore = Path ${remoteMusicFolder#$remoteDocumentsFolder/}" >> $fileName
		echo "ignore = Path ${remotePicturesFolder#$remoteDocumentsFolder/}" >> $fileName
		echo "" >> $fileName
	fi
	
	
	
}

function buildPersonalLaunchAgent() {
# incomplete

# Prepare WatchPaths taken in as Arguments
while [ $# -ne 0 ];	do
		quotedText=\"$1\"
		watchPaths="${watchPaths}$quotedText"
		if ! [ $# -eq 1 ]; then
			watchPaths="${watchPaths}, "
		fi
		shift
done

# Build Plist Structure
plist="{ "Label" = "com.sync.user"; "ProgramArguments" = ( "/usr/local/scripts/sync.sh"); }"
defaults write ~/Library/LaunchAgents/com.sync.user "$plist"

# Add Options
defaults write ~/Library/LaunchAgents/com.sync.user onDemand -bool True
defaults write ~/Library/LaunchAgents/com.sync.user RunAtLoad -bool True

# Add watchpaths
defaults write ~/Library/LaunchAgents/com.sync.user WatchPaths "( $watchPaths )"

# Convert to XML
plutil -convert xml1 ~/Library/LaunchAgents/com.sync.user.plist

# Set correct permissions
chmod 644 ~/Library/LaunchAgents/com.sync.user.plist
}

# Prepare 'unison' profiles
# Profiles are specific to 'unison' they provide default sync settings for various
# scenarios and reduce the amount of flags required in running the sync command
if ! [ -d $HOME/.unison ]; then
	mkdir $HOME/.unison
	cd $HOME/.unison
	#touch home_common.prf home_docs.prf home_movies.prf home_music.prf home_pics.prf

	#create profiles
	buildProfile "home_common.prf"
	buildProfile "home_root.prf" "$HOME" "$remoteHome"
	buildProfile "home_docs.prf" "$HOME/Documents" "$remoteHome/$remoteDocumentsFolder"
	buildProfile "home_movies.prf" "$HOME/Movies" "$remoteHome/$remoteMoviesFolder"
	buildProfile "home_music.prf" "$HOME/Music" "$remoteHome/$remoteMusicFolder"
	buildProfile "home_pics.prf" "$HOME/Pictures" "$remoteHome/$remotePicturesFolder"
	
fi

if ! [ -f $HOME/Library/LaunchAgents/com.sync.user.plist ]; then
	echo "Creating 'com.sync.user'"
buildPersonalLaunchAgent $HOME $HOME/Desktop $HOME/Downloads \
$HOME/Movies $HOME/Music $HOME/Pictures
fi
