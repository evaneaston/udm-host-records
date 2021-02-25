#!/bin/sh
set -e

. $(dirname "$0")/common.sh

usage() {
    echo "Usage $0 hostname\n"
}

if [ "$#" -ne 1 ] ; then
    echo "Invalid number of arguments.\n"
    usage
    exit 1
fi

export host=$(trim "$1")
updateServices '. | del( .dnsForwarder.hostRecords[] | select((.hostName | ascii_downcase) == (env.host | ascii_downcase)))'
