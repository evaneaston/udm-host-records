trim() {
    echo "$1" | sed -e 's/^[ ]*//' | sed -e 's/[ ]*$//'
}


cmd=ubios-udapi-client
if [ "$TEST" = "1" ]; then
    cmd=./mock-ubios-udapi-client.sh
fi

updateServices() {
    tmpfile=/tmp/dnsForwarderUpdates-$$.json
    $cmd GET -r /services | jq -c "$1" > "$tmpfile"
    cat "$tmpfile"
    $cmd PUT /services "@$tmpfile"
    rm "$tmpfile"
}
