#!/bin/bash
echo $IPRED_USER > $IPRED_AUTH_FILE
echo $IPRED_PASSWORD >> $IPRED_AUTH_FILE
# Couldn't find a way to build this into the image
sysctl -p /etc/sysctl.conf

# Create tun0 so unprivileged user openvpn can use it
openvpn --rmtun --dev tun0
openvpn --mktun --dev tun0 --dev-type tun --user openvpn --group openvpn

# restrict dns lookup to openvpn server only
NS=$(host dns | grep "dns has address" | awk '{print $4}')
# docker-compose defaults us to using a name service on 127.0.0.11
echo "nameserver $NS" > /etc/resolv.conf

iptables -F 

# Prevent connections from VPN to our transmission management port
# We bind only to the local interface, but just in case
iptables -A INPUT -i tun0 -p tcp --destination-port 9091 -j DROP

iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Only allow DNS to ipredator dns servers that only function when on vpn
iptables -A OUTPUT -d 194.132.32.23 -p udp -m udp --dport 53 -j ACCEPT
iptables -A OUTPUT -d 46.246.46.46 -p udp -m udp --dport 53 -j ACCEPT
# This is primarily so we can hit the dns container
iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 53 -j DROP
# For some reason just blocking udp:53 isn't enough to prevent dns getting out on loopback
# So only allowing tcp out. docker-compose sets up dns on 127.0.0.11 which we don't
# want to query since it won't be on the VPN
iptables -A OUTPUT -p tcp -m tcp -o lo -j ACCEPT
#iptables -A OUTPUT -o lo -p tcp -m tcp -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT
# This is what allows openvpn client to function
iptables -A OUTPUT -p udp --dport 1194 -m owner --gid-owner openvpn -j ACCEPT
iptables -A OUTPUT -j DROP

# Need to change perms so up script can update dns in up/down.sh
touch /etc/resolv.conf.before_vpn

chown openvpn:openvpn /etc/resolv.conf*
chmod u+w /etc/resolv.conf
exec sudo -u openvpn /usr/sbin/openvpn --config /etc/openvpn/IPredator-CLI-Password.conf
