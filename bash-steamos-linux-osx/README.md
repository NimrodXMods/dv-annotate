# dv-annotate bash scripts

These are bash scripts I hacked together help with bug reports. I threw these together quickly just for myself, so they’re pretty minimal. But I fixed them up some in case anyone else wants to use them. They're roughly the equivalent of the windows utility in the `../windows` directory.

I use these on SteamOS but they should work on any Linux and probably OSX if the pathnames are set properly. (The default pathnames are what is needed on SteamOS on a Steam Deck.)

Extract all of these to the same directory and run as `./` cd'd to that directory.

## `dv-archive.include.sh`

Edit this to set pathnames and such for screenshots. Not much needs changing here, but OSX will need more changes.

## `dv-annotate`

Run this to save a comment plus the timestamp of when you started the script and the file name of the most recent screenshot in the screenshots dir.

## `dv-archive`

Run this to archive the dV game directory along with the annotations and screenshots taken since the first annotation.

## `dv-show-annotations`

Run this to review current annotations or the ones in the most recent archive.