#!/bin/bash
# Start the transmission-daemon and bind us to local and vpn ip addresses
# To lock down access and prevent leaks

if [[ "$LOGNAME" != "transmission" ]]; then
    echo "Only run this as transmission"
    exit 1
fi

# Wait till we're connected and routable. Had issues with transmission not binding properly
CURL_GOOGLE="curl --silent --max-time 15 --proxy 'http://proxy.ipredator.se:8080' 'http://www.google.se' > /dev/null"
echo "Waiting for connection with: $CURL_GOOGLE"
until eval $CURL_GOOGLE
do
    echo "Retrying $CURL_GOOGLE"
done


function get_vpn_ip() {
    /sbin/ip addr show tun0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
}

VPN_IP=$(get_vpn_ip)
LOCAL_IP=`/sbin/ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`
echo "VPN IP is '$VPN_IP', Local IP is '$LOCAL_IP'"
if [[ ! "$VPN_IP" || ! "$LOCAL_IP" ]]; then
    echo "Could not detect IPs."
    exit 1
fi


# Launch transmission-daemon with bound to IP addresses to prevent accidentally
# sending traffic outside of the VPN

TD_NAME="/usr/local/bin/transmission-daemon"
TM_LOG="/var/log/transmission-daemon/transmission-daemon.log"
echo "Killing any existing $TD_NAME's"
pkill -9 -f "$TD_NAME"

TM_CMD="$TD_NAME --bind-address-ipv4 $VPN_IP \
        --rpc-bind-address $LOCAL_IP \
        --allowed 127.0.0.1,192.168.*.*,172.18.*.* \
        --logfile $TM_LOG \
        --encryption-preferred \
        --global-seedratio 1.0 \
        --download-dir /mnt/Downloads_In_Progress \
        --incomplete-dir /mnt/Downloads_In_Progress \
        --dht --lpd --utp"

TAIL_CMD="tail -F $TM_LOG"
pkill -f "$TAIL_CMD"
$TAIL_CMD &

echo Running: $TM_CMD
$TM_CMD
while true; do
    if [[ "$(get_vpn_ip)" != "$VPN_IP" ]]
    then
        echo "VPN IP '$VPN_IP' changed to '$(get_vpn_ip)', exiting."
        exit 1
    elif ! pgrep -f "$TD_NAME" > /dev/null
    then
        echo "transmission-daemon exited, exiting."
        exit 1
    fi
    echo "VPN IP ($VPN_IP) has not changed, transmission-daemon stil present, sleeping..."
    sleep 120
done

