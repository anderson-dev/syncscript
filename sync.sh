#!/bin/sh

# This script will be used to perform initial sync of the user's home directory

/usr/local/bin/unison home_root
/usr/local/bin/unison home_docs
/usr/local/bin/unison home_movies
/usr/local/bin/unison home_music
/usr/local/bin/unison home_pics

