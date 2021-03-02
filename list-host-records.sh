#!/bin/sh
set -e
. $(dirname "$0")/common.sh
$cmd GET -r /services | jq ".dnsForwarder.hostRecords[] | {address: .address.address, hostName, registerNonQualified, ipVersion: .address.ipVersion}"
