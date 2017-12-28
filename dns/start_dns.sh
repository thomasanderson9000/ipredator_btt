#!/bin/bash
# Setup dnsmasq to only get us the ip for the openvpn server

# We'll read the vpn servert name from here
export VPN_SERVER_FILE=/vpn_server.txt

# Start a xmlrpc server and wait for a request with the dns hostname we're going to use
# and write it out to VPN_SERVER_FILE
# Server will not write it again (covers container restart)
python -u /root/set_dns.py &

while [ ! -f "$VPN_SERVER_FILE" ]
do
 	echo "Waiting for xmlrpc caller ..."
	sleep 2
done

NS=$(grep nameserver /etc/resolv.conf | head -n 1 | awk '{print $2}')

ARGS=""
SERVERS=$(cat $VPN_SERVER_FILE)
for SERVER in $SERVERS
do
    ARGS="--server=/${SERVER}/${NS} $ARGS"
done

echo "Starting dns server for $VPN_SERVER"
# Replace current process with the dns server
exec dnsmasq --user=root --no-resolv --log-queries --keep-in-foreground --log-facility=- $ARGS

