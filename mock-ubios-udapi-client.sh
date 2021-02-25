#!/bin/sh
set -e

if [ "$1" = "GET" -a "$2" = "-r" -a "$3" = "/services" ]; then 
    cat testdata.json
elif [ "$1" = "PUT" -a "$2" = "/services" -a  "@${3#\@}" = "$3" ]; then
    if [ ! -f ${3#\@} ]; then
        echo "File ${3#\@} doesn't exist"
        exit 1
    fi
    cat ${3#\@}
else
    echo "Unsupported usage: $0 $@"
    exit 1
fi