#!/bin/sh
#
# See dv-archive for info.
#

. ~/dv-archive.include.sh

while getopts ":p" option; do
   case $option in
      p | l) # show previous annotations
	 lasttgz=`find $sharedir -maxdepth 1 -type f -printf "%T@ %P\n" | sort -nr | head -n 1 | cut -d' ' -f 2-`
	 echo "*** Showing annotations in $lasttgz :"
	 tar Ozxf $sharedir/$lasttgz ./$readme
         exit;;
   esac
done

# otherwise show current annotations
echo "*** Contents of $dvreadme :"
cat $dvreadme
exit
