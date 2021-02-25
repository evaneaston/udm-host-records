#!/bin/sh
set -e

. $(dirname "$0")/common.sh

usage() {
    echo "Usage $0 hostname ipaddress { registernonqualified }\n\n  registernonqualified      true | false (true is default)\n"
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ] ; then
    echo "Invalid number of arguments.\n"
    usage
    exit 1
fi

if [ "$#" -eq 3 ] ; then
    if [ "$3" != "false" ] && [ "$3" != "true" ] ; then
        echo "Last argument must be true or false, or omitted.\n"
        usage
        exit 2
    fi
fi

export host=$(trim "$1")
export ip=$(trim "$2")
export regNonQual=${3:-true}
updateServices '.dnsForwarder.hostRecords |= (. | map(. + { key: (.hostName | ascii_downcase), value: (.)}) | from_entries | . + ({ (env.host | ascii_downcase):{address:{address: (env.ip), origin: null}, hostName: (env.host), registerNonQualified: ("true" == env.regNonQual)}}) | to_entries | map(.value))'
