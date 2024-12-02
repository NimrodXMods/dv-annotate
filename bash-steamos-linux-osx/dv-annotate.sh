#!/bin/sh
#
# See dv-archive for info.
#

. ~/dv-archive.include.sh

echo "Annotating dV using $dvreadme"
echo "Enter single line below and hit Enter."
echo "(libreadline editing keys allowed)"
echo "Most recent screenshot will be found after hitting Enter."
read -e -p "$timestamp -- " annotation

lastscreenshot=`find $ssdir -maxdepth 1 -type f -printf "%T@ %P\n" | sort -nr | head -n 1 | cut -d' ' -f 2-`
echo "Adding most recent screenshot: $lastscreenshot"

out="$timestamp -- $annotation [$lastscreenshot]"
echo $out >> $dvreadme
echo "Done!"
