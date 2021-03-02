#!/bin/sh
set -e

. $(dirname "$0")/common.sh

host=
ip=
ipVersion=v4
regNonQual=true

usage() {
    echo "Usage $0 {-f} {-v 4|6} hostname ipaddress\n\n  -f     FQDN only.  Sets registerNonQualified=false on the host record.  Defaults to true.\n  -v     4 or 6.  Defaults to 4.  Ignored by UDM firmware < 1.9.\n"
}

setIpVersion() {
    if echo "$1" | grep -q "^v\?4$"; then
        ipVersion=v4
    elif echo "$1" | grep -q "^v\?6$"; then
        ipVersion=v6
    else
        echo "Invalid IP version option.  Must be 4 or 6."
        usage
    fi
}


handleArgument() {
    if [ "${host}" = "" ]; then
        host=$(echo "$1")
    elif  [ "${ip}" = "" ]; then
        ip=$(echo "$1")
    else
        echo "Invalid number of arguments.\n"
        usage
        exit 1
    fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -f) regNonQual=false; shift 1;;
    -v) setIpVersion "$2"; shift 2;;   
    -*) echo "unknown option: $1" >&2; exit 1;;
    *) handleArgument "$1"; shift 1;;
  esac
done

if [ "${host}" = "" ]; then
    echo "Host not specified\n"
    usage
    exit 1
fi
if [ "${ip}" = "" ]; then
    echo "IP not specified\n"
    usage
    exit 1
fi


echo host=${host}
echo ip=${ip}
echo ipVersion=${ipVersion}
echo regNonQual=${regNonQual}

export host
export ip
export regNonQual
export ipVersion

updateServices '.dnsForwarder.hostRecords |= (. | map(. + { key: (.hostName | ascii_downcase), value: (.)}) | from_entries | . + ({ (env.host | ascii_downcase):{address:{address: (env.ip), origin: null, version: (env.ipVersion)}, hostName: (env.host), registerNonQualified: ("true" == env.regNonQual)}}) | to_entries | map(.value))'

echo "\nCurrent host records"
./list-host-records.sh
