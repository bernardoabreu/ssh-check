#!/bin/bash

USER=$(whoami);

NOTOCC=true;
TIMEOUT=5;

# parse the options
while getopts 'ou:t:h' opt ; do
    case $opt in
        o) NOTOCC=false;;
        u) USER=$OPTARG;;
        t) TIMEOUT=$OPTARG;;
        h) echo "Options: -u user (default: $(whoami))";
           echo "Options: -o allow occupied (default: don't allow)"
           exit 0 ;;
    esac
done

# skip over the processed options
shift $((OPTIND-1));

INPUT_FILE=$1;

while read -r MACHINE; do
    if $NOTOCC; then
        if [[ ! $((ssh -o ConnectTimeout="${TIMEOUT}" "${USER}@${MACHINE}" -n -tt who 2> /dev/null || echo "NOT OK") | grep -v "$USER ") ]]; then
            echo $MACHINE;
        fi;
    else
        ssh -o ConnectTimeout="${TIMEOUT}" "${USER}@${MACHINE}" -n -tt who &> /dev/null && echo $MACHINE;
    fi;
done < "$INPUT_FILE";
