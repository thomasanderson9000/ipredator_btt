#!/bin/bash
echo $IPRED_USER > $IPRED_AUTH_FILE
echo $IPRED_PASSWORD >> $IPRED_AUTH_FILE
# Couldn't find a way to build this into the image
sysctl -p /etc/sysctl.conf

# Create tun0 so unprivileged user openvpn can use it
openvpn --rmtun --dev tun0
openvpn --mktun --dev tun0 --dev-type tun --user openvpn --group openvpn
# Prevent connections from VPN to our transmission management port
# We bind only to the local interface, but just in case
/sbin/iptables -A INPUT -i tun0 -p tcp --destination-port 9091 -j DROP
# Need to change perms so up script can update dns
touch /etc/resolv.conf.before_vpn
chown openvpn:openvpn /etc/resolv.conf*
exec sudo -u openvpn /usr/sbin/openvpn --config /etc/openvpn/IPredator-CLI-Password.conf
