# udm-host-records

Scripts to list, add, update, and remove host records in the Ubiquiti UniFI Dream Machine DNS forwarder.

# Description

As of the creation of this repo, UDMs do not have a UI for administering host records.  But the DNS forwarder running on the device supports them.  If you don't already run your own DNS service and want to be able to resolve hosts by name in your UDM networks, you can add host records.  But it's tedious.

The UDMs no longer resolve against the `/etc/hosts` file.  Instead they use records that must be administered via API.  You can edit them via code by `GET`'ting the `/services` endpoint to get the json response, changing the entries in `dnsForwarder`.`hostRecords`, and `PUT`'ting the the updated json back to the `/services` endpoint.  This was well documented in [this community topic](https://community.ui.com/questions/UDM-Base-How-to-add-static-hostname-for-dnsmasq-forwarder/88354ba8-2b7e-443c-8031-7ac680dafd47).

These scripts should make the process a little easier.

Once scripts are executed
* the changes take effect immediately
* host records will persist restarts and become part of backups.

# Verify Assumptions

*  *Have you configured your local networks to use nameservers other than the UDM?  If so, these scripts won't help you.  You need to set each local network's **DHCP Name Server** to automatic or to the ip of the UDM.  You can still use alternate DNS servers ouside your network.  You will juat need to config your WAN networks to forward to these DNS servers.*
*  *These scripts do nothing with client aliases. While it wouldn't be a stretch to add a script that will capture all client aliases and the network domains and automatically register host records for each,that's not what these scripts do...yet ;)*

# Install

1. Download - Clone this repo or use the **Code** > **Download Zip** github button to download a zip containing the repo code.
2. Copy the code to the UDM to a directory of your choosing, such as `/mnt/data/udm-host-records`
3. Make sure script execution permissions in case they didn't survive the download and copy.   If they didn't then, 
```
cd /mnt/udm-host-records
chmod u+x *.sh
```

# Run

## List Host Records 

To see what host records are present, use

```
list-host-records.sh
```

## Add or Change a Host Record

To create or update a host record, use

```
./add-host-record.sh {-f} {-v 4|6} <hostname>.<domain> <ipaddress>

  -f     FQDN only.  Sets registerNonQualified=false on the host record.  Defaults to true.
  -v     4 or 6.  Defaults to 4.  Ignored by UDM firmware < 1.9.
```

```
./add-host-record.sh coffee-machine.yourlocaldomain.com 192.168.8.43
```

will allow you to resolve your coffee-machine's IP address using `coffee-machine.yourlocaldomain.com` or just simply `coffee-machine`.

Just like in an `/etc/hosts` file, you can add multiple entries for any given IP.

If you want to change the IP of an existing host entry, run the command again with the new IP address.

## Remove a Host Entry

To remove a host record, use

```
./remove-host-record.sh <hostname>.<domain>
```

# Disclaimers / Warnings

* This code makes no backups.  Use at your own risk.  **MAKE YOUR OWN BACKUPS BEFORE USING**
* It relies on the UDM `PUT /services` API to validate the updated JSON it PUTs back to the API.
* It may stop working at any time if Ubiquiti changes how the `/services` works or the structure of the json content it accepts.

# Testing

To simplify development while I was tweaking the `jq` commands, I made a [mock ubios-udapi-client script](./mock-ubios-udapi-client.sh) that I run locally when the `TEST` env var is set to `1`.  It will  simply echo the `testdata.json` from the same directory as the scripts whenever the scripts GET the `/services` endpoint.  It will also result in the changed json file being echo'ed to stdout whenever it PUTs the JSON to the '/services' endpoint.

If you want to experiment, 

1. get a copy of the `/services` config json by running the command `ubios-udapi-client GET /services > testdata.json` on your UDM.  Place this `testdata.json` in the same directory as the scripts where you are going to edit and test them
   * NOTE THAT THIS MAY CONTAIN SENSITIVE INFORMATION IN PLAINTEXT FORM.  SECURE AND RETAIN IT ACCORDINGLY.
2. run the commands with `TEST=1 ` before them, e.g.

```
TEST=1 ./list-host-records.sh ...
```

```
TEST=1 ./add-host-record.sh ...
```

```
TEST=1 ./remove-host-record.sh ...
```


