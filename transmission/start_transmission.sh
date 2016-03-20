#!/bin/bash
# Start the transmission-daemon and bind us to local and vpn ip addresses
# To lock down access and prevent leaks

function get_vpn_ip() {
    /sbin/ip addr show tun0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
}

function restart_me() {
    # Call myself 
    exec "${BASH_SOURCE[0]}"
}

if [[ "$LOGNAME" != "transmission" ]]; then
    echo "Only run this as transmission"
    exit 1
fi

# Directory where script is stored
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Bootstrap our named volume if it hasn't been yet
TD_CONFIG=$DIR/.config/transmission-daemon
if [[ ! -e "$TD_CONFIG" ]]; then
    mkdir -p $TD_CONFIG 
    # A few transmission settings are not settable on the command line so we need this
    # https://blog.ipredator.se/howto/restricting-transmission-to-the-vpn-interface-on-ubuntu-linux.html
    cp $DIR/settings.partial.json $TD_CONFIG/settings.json
else
    echo "Re-using existing settings.json from persistent data volume."
fi

TRANSMISSION_DAEMON_ARGS=$(cat $DIR/transmission-daemon-extra-args)
if [[ ! "$TRANSMISSION_DAEMON_ARGS" ]]; then
    echo "No extra arguments found for transmission-daemon."
    echo "They can be added by setting them in transmission-daemon-extra-args"
fi

# Wait till we're connected and routable. Had issues with transmission not binding properly
CURL_GOOGLE="curl --silent --max-time 15 --proxy 'http://proxy.ipredator.se:8080' 'http://www.google.se' > /dev/null"
echo "Waiting for connection with: $CURL_GOOGLE"
until eval $CURL_GOOGLE
do
    echo "Retrying $CURL_GOOGLE"
    sleep 5
done


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
        --download-dir /mnt/Downloads_Completed \
        --incomplete-dir /mnt/Downloads_In_Progress \
        --logfile $TM_LOG $TRANSMISSION_DAEMON_ARGS"

TAIL_CMD="tail -F $TM_LOG"
pkill -f "$TAIL_CMD"
$TAIL_CMD &

echo Running: $TM_CMD
$TM_CMD
while true; do
    if [[ "$(get_vpn_ip)" != "$VPN_IP" ]]
    then
        echo "VPN IP '$VPN_IP' changed to '$(get_vpn_ip)', restarting."
        restart_me
    elif ! pgrep -f "$TD_NAME" > /dev/null
    then
        echo "transmission-daemon exited, restarting."
        restart_me
    fi
    echo "VPN IP ($VPN_IP) has not changed, transmission-daemon stil present, sleeping..."
    sleep 120
done

# Should never exit, but just in case
exit 1
