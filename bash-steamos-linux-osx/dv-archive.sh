#!/bin/sh
#
# dv-archive - archive Delta V: Rings of Saturn game files and logs for debugging.
#     Includes annotations created with dv-annotate.
#     A hacked together script by NimrodX
#     Also see dv-annotate and dv-show-annotations.

# Edit the file below for your user-specific settings.
. ~/dv-archive.include.sh

read -e -p "Edit archive filename: " -i $tgzname tgzname_edited

echo "Creating new $dvssdir directory..."
rm -rf $dvssdir
mkdir $dvssdir
dvreadme_start_time=`head -1 $dvreadme | cut -d' ' -f1 | sed 's/\./:/g'`
echo "Copying screenshots since first timestamp in $dvreadme ($dvreadme_start_time)..."
find $ssdir -maxdepth 1 -type f -newermt $dvreadme_start_time -print -execdir cp '{}' $dvssdir \;
echo "Screenshots copied to $dvssdir"

echo "Archiving game directory..."
cd $sharedir
echo "$timestamp -- Archived game directory with screenshots." >>$dvreadme
tar czvf $tgzname_edited ./dV
echo "Archive saved in $sharedir/$tgzname_edited"

echo "Removing old $dvssdir ..."
rm -rf $dvssdir

echo "Resetting annotations file ($dvreadme)..."
rm -f $dvreadme
echo "$timestamp -- File cleared. Screenshots newer than this time are in the _screenshots folder." >>$dvreadme
echo "$timestamp -- (jpg filename is a timestamp, screenshots may or may not all be relevant)" >>$dvreadme
echo "Annotations cleared."
