#!/usr/bin/env python
from __future__ import print_function
from subprocess import call
from time import sleep
import shlex
import socket
import xmlrpclib
import os
import re
import os.path

BASE_DIR = '/etc/openvpn'

def run(cmd):
    print("Running: {}".format(cmd))
    exit_code = call(cmd, shell=True)
    print("Exit Code: {} From: {}".format(exit_code, cmd))


def easy_exec(cmd):
    """Make os.exec friendly"""
    args = shlex.split(cmd)
    print("Running '{}' args '{}'".format(args[0], args))
    os.execvp(args[0], args)

def env_vars_defined(env_vars):
    """Exit if any of the named environment vars are not defined."""
    missing = False
    for env_var in env_vars:
        if env_var not in os.environ.keys():
            missing = True
            print("Missing environment variable {}".format(env_var))
    if missing:
        os.exit(1)

def setup_system():
    # Couldn't find a way to build this into the image
    run("sysctl -p /etc/sysctl.conf")
    # Create tun0 so unprivileged user openvpn can use it
    run("openvpn --rmtun --dev tun0")
    run("openvpn --mktun --dev tun0 --dev-type tun --user openvpn --group openvpn")
    # openvpn will write out dns info in up/down so it needs perms
    run("chown openvpn:openvpn /etc/resolv.conf*")
    run("chmod u+w /etc/resolv.conf")
    # openvpn down script will copy the settings back
    run("cp /etc/resolv.conf /etc/resolv.conf.before_vpn")

def write_vpn_auth_file(vpn_file, vpn_user, vpn_password):
    """Write vpn user/pass to the openvpn auth file."""
    with open(vpn_file, 'w') as fh:
        fh.write("{}\n".format(vpn_user))
        fh.write("{}\n".format(vpn_password))

def change_nameserver_to_dns_container():
    """Update resolv.conf with ip from dns container (which provides dns)"""
    nameserver_dns = socket.gethostbyname('dns')
    with open('/etc/resolv.conf', 'w') as fh:
        fh.write("nameserver {}".format(nameserver_dns))

def create_firewall(vpn_ports):
    """Firewall only allows traffic to dns container and through openvpn."""
    print("Creating firewall")
    run("iptables -F")
    # Prevent connections from VPN to our transmission management port
    # We bind only to the local interface, but just in case
    run("iptables -A INPUT -i tun0 -p tcp --destination-port 9091 -j DROP")

    run("iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT")
    # This is primarily so we can hit the dns container
    run("iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT")
    # For some reason just blocking udp:53 isn't enough to prevent dns getting out on loopback
    # So only allowing tcp out. docker-compose sets up dns on 127.0.0.11 which we don't
    # want to query since it won't be on the VPN
    run("iptables -A OUTPUT -p tcp -m tcp -o lo -j ACCEPT")
    # Everything allowed out on the vpn
    run("iptables -A OUTPUT -o tun0 -j ACCEPT")
    # This is what allows openvpn client to function
    for vpn_port in vpn_ports:
        print("Opening access to port {}".format(vpn_port))
        run("iptables -A OUTPUT -p udp --dport {} -m owner --gid-owner openvpn -j ACCEPT".format(vpn_port))
    run("iptables -A OUTPUT -j DROP")

def get_vpn_ports(vpn_file):
    """Get VPN ports from ovpn file"""
    with open(vpn_file, 'r') as fh:
        contents = fh.read()
    return re.findall(r"^remote .+? (\d+)", contents, re.MULTILINE)

def set_allowed_dns(vpn_file):
    """Tell dns server what gateways are OK to lookup"""
    # Get gateways from ovpn file
    with open(vpn_file, 'r') as fh:
        contents = fh.read()
    gateways = re.findall(r"^remote (.+?) \d+", contents, re.MULTILINE)
    print("Found gateways {}".format(", ".join(gateways)))

    # Connect to xmlrpc server on dns container
    proxy = xmlrpclib.ServerProxy("http://dns:80/")
    while True:
	try:
	    print(proxy.set_vpn_gateways(gateways))
            return
	except socket.error as e:
	    print("dns xmlrpc not available yet, waiting...")
	    sleep(5)

def openvpn(vpn_file, auth_file):
    """Run openvpn with vpn_file form that directory."""
    os.chdir(os.path.dirname(vpn_file))
    if not os.path.isfile(vpn_file):
        print("Could not find ovpn file {}".format(vpn_file))
        os.exit(1)
   # Replace current process with openvpn process
    easy_exec('gosu openvpn /usr/sbin/openvpn ' +
                '--config "{}" '.format(vpn_file) +
                '--dev tun0 ' +
                '--auth-user-pass {} '.format(auth_file) +
                '--iproute /usr/local/sbin/unpriv-ip ' +
                '--script-security 2 ' +
                '--up-restart ' +
                '--up {}/update-resolv-conf.py '.format(BASE_DIR) +
                '--down {}/update-resolv-conf.py'.format(BASE_DIR))


if __name__ == "__main__":
    env_vars_defined(['VPN_USER', 'VPN_PASSWORD', 'VPN_AUTH_FILE', 'OVPN_FILE'])
    setup_system()
    write_vpn_auth_file(os.environ['VPN_AUTH_FILE'],
                        os.environ['VPN_USER'],
                        os.environ['VPN_PASSWORD'])
    ovpn_file="{}/{}".format(BASE_DIR, os.environ['OVPN_FILE'])
    set_allowed_dns(ovpn_file)
    # restrict dns lookup to openvpn server only
    # docker-compose defaults us to using a name service on 127.0.0.11
    change_nameserver_to_dns_container()
    create_firewall(vpn_ports=get_vpn_ports(ovpn_file))
    # chown'ing before this point doesn't seem to stick
    run("chown openvpn:openvpn /etc/resolv.conf*")
    run("chmod u+w /etc/resolv.conf")
    openvpn(vpn_file=ovpn_file,
            auth_file=os.environ['VPN_AUTH_FILE'])

