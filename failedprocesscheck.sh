#!/bin/bash

# Written by Niko Janceski (@deathanchor)

# defaults
MMIN=+0  # only files older than this many minutes
WARNING=0  # warn if it has this or more failure occurances
CRITICAL=1 # critical if it has this or more failure occurances
FAILUREDIR='/opt/log/failalert' # directory containing failure files should usually be empty

USAGE="
    usage: $0 [-c <CRITICAL>] [-w <WARNING>] [-f <FAILUREDIR>] [-m <MMIN>] [-i]
    this will search files in the FAILUREDIR for files older than MMIN minutes
    Critical ($CRITICAL) or Warning ($WARNING) if that many or more failures occurred in the files.
    -f <FAILUREDIR> = directory containing alert file ($FAILUREDIR)
    -m <MMIN> = only look at files that are this old (-10 = <10 min old, default $MMIN)
    -i = ignore if FAILUREDIR is missing (will return OK instead of UNKNOWN)
"

IGNOREMISSINGDIR=0
while getopts ':c:w:m:f:i' opt; do
    case $opt in
        c)
            CRITICAL=$OPTARG
            ;;
        w)
            WARNING=$OPTARG
            ;;
        m)
            MMIN=$OPTARG
            ;;
        f)
            FAILUREDIR=$OPTARG
            ;;
        i)
            IGNOREMISSINGDIR=1
            ;;
        \?)
            echo "UNKNOWN OPTION"
            echo "$USAGE"
            exit 3
            ;;
    esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

# warn if dir is not there/readable/exec, can't be sure that things can write/read from there
if [[ ! ( -d $FAILUREDIR && -r $FAILUREDIR && -x $FAILUREDIR ) ]]; then
    if [[ $IGNOREMISSINGDIR == 1 && ! -d $FAILUREDIR ]]; then
        echo "OK - $FAILUREDIR is missing (ignore on)"
        exit 0
    fi
    echo "UNKNOWN - $FAILUREDIR doesn't exist or bad permissions"
    exit 3
fi

FINDCMD="find $FAILUREDIR -follow -maxdepth 1 -mmin $MMIN -type f -exec wc -l {} ;";

# below magic from http://stackoverflow.com/questions/13806626/capture-both-stdout-and-stderr-in-bash
# grab errors and stdout separately (stdout into an array by spaces)
eval "$( {
    errors=$({ 
            results=( $( $FINDCMD ) );
            } 2>&1; 
        declare -p results >&2);
    declare -p errors; 
} 2>&1 )"

if [[ ! -z $errors ]]; then
    echo "CRITICAL - check failed: ${errors}";
    exit 2
fi


hasCritical=0;
hasWarnings=0;
critFiles=();
warnFiles=();
filecount=$(( ${#results[*]} / 2 ));

for (( i = 0; $i < ${#results[*]}; i = $i + 2 )); do
    count=${results[$i]};
    filename=$(basename ${results[$(( $i +1 ))]} );
    # echo "$count = $filename";
    if [[ $count -gt $CRITICAL ]]; then
        ((hasCritical++));
        critFiles+=($filename);
    elif [[ $count -gt $WARNING ]]; then
        ((hasWarnings++));
        warnFiles+=($filename);
    fi
done;


if [[ $hasCritical -gt 0 ]]; then
    echo "CRTICAL - $hasCritical files over $CRITICAL lines"
    printf "%s\n" "${critFiles[@]}"
    exit 2
elif [[ $hasWarnings -gt 0 ]]; then
    echo "WARNING - $hasWarnings files over $WARNING lines"
    printf "%s\n" "${warnFiles[@]}"
    exit 1
else
    echo "OK - $FAILUREDIR contain $filecount files under $WARNING lines"
    exit 0
fi


