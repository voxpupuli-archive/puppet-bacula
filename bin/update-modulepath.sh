#!/bin/bash
MODULEPATH="$1"

if [ -z "$MODULEPATH" ] ; then
    echo "
You must specifiy the location where your modules are installed as the first 
argument to this script
./bin/update-modulepath.sh /etc/puppet/modules
" >&2
    exit 1
fi
if [ ! -f Modulefile ] ; then
    echo "
This script is meant to be run from the root of the module project.
Please change directories to the repository root and run the script again.
./bin/update-modulepath.sh /etc/puppet/modules 
" >&2
    exit 1
fi
RSYNC_ARGS='-aCmhiH'
EXCLUDE='.git .project bin'
RSYNC_EXCLUDE=''

for exclude_string in $EXCLUDE ; do
    RSYNC_EXCLUDE="${RSYNC_EXCLUDE} --exclude=${exclude_string} "
done

rsync $RSYNC_ARGS $RSYNC_EXCLUDE --delete ./ $MODULEPATH/bacula
