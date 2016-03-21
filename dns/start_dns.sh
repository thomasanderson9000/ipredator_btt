#!/bin/bash
# Setup dnsmasq to only get us the ip for the openvpn server

NS=$(grep nameserver /etc/resolv.conf | head -n 1 | awk '{print $2}')

dnsmasq --user=root --no-resolv --log-queries --keep-in-foreground --log-facility=- \
        --server=/pw.openvpn.ipredator.se/$NS \
        --server=/pw.openvpn.ipredator.me/$NS \
        --server=/pw.openvpn.ipredator.es/$NS 

