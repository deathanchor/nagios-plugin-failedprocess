#!/bin/bash

# written by Nikola Janceski

# vim:expandtab
# vim:shiftwidth=4
# vim:foldenable

STARTED=`date`
DEFDIR=/opt/log/failalert
DEFFILE=$(basename $0)
set ${ALERTDIR:=$DEFDIR}
set ${ALERTFILE:=$DEFFILE}

HASERRORS=0
STARTDIR=`pwd`

{
    set -o errexit
    mkdir -p $ALERTDIR
}

function failedproc(){
    HASERRORS=1
    echo -n started: $STARTED >> $ALERTDIR/$ALERTFILE
    echo -n '; startdir:' $STARTDIR >> $ALERTDIR/$ALERTFILE
    echo '; cmd:' $0 >> $ALERTDIR/$ALERTFILE
}

function successproc(){
    # removed only if successful
    echo ERRORS: $HASERRORS
    if [[ $HASERRORS == 0 ]]; then
        rm -f $ALERTDIR/$ALERTFILE
    fi
}

# if any command fails, alert!
trap failedproc ERR

# check last command success
trap successproc EXIT

