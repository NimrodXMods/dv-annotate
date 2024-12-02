# See dv-archive and other utilties.
# This is the configuration for those.
#
# Set steamid to what you see in .local/share/Steam/userdata/XXXXXXXX
# if using Steam. Otherwise ignore this and see below.
#
steamid=64755991
#
# Set archivetag to some sort of identifier for the
# archive filename, like your discord or steam username.
#
archivetag=NimX
#
# This should be where the dV directory (game data folder)
# is stored. (Not the dV folder iteself.)
#
sharedir=~/.local/share
#
# Change ssdir to a different screenshots folder if not using Steam.
#
ssdir=$sharedir/Steam/userdata/$steamid/760/remote/846030/screenshots

### The rest shouldn't need changing.

# Note that this gets set when a script is started.
timestamp=`date -Iminutes`
filesafe_timestamp=${timestamp//:/.}

dvssdir=$sharedir/dV/_screenshots
tgzname=dV-$archivetag-$filesafe_timestamp.tgz
readme=dV/_README
dvreadme=$sharedir/$readme
