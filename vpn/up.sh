#!/bin/bash
cp /etc/resolv.conf /etc/resolv.conf.before_vpn 
# Change to IPRedator DNS once we're connected https://www.ipredator.se/page/services#service_dns
# Otherwise we leak dns
printf "nameserver 194.132.32.23\nnameserver 46.246.46.46\n" > /etc/resolv.conf
