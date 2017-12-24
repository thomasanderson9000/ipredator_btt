#!/bin/bash

/replace_env_vars.py --input_file config.yml --output_file /flexget/config.yml

CURL_TRANSMISSION="curl --silent --max-time 15 'http://vpn:9091/transmission/web/' > /dev/null"
echo "Waiting for connection with: $CURL_TRANSMISSION"
until eval $CURL_TRANSMISSION
do
    echo "Retrying $CURL_TRANSMISSION"
    sleep 5
done

cd /flexget
while :
do
    flexget execute
    sleep 1800
done
