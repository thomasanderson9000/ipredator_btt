#!/bin/bash
cp /etc/resolv.conf /etc/resolv.conf.before_vpn 
printf "nameserver 194.132.32.23\nnameserver 46.246.46.46\n" > /etc/resolv.conf
