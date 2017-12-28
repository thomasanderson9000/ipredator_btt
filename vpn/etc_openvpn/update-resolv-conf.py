#!/usr/bin/env python
"""Call this from --up/--down via openvpn.
   Writes out dns from openvpn
   Resets dns from backup file after."""

from __future__ import print_function
import os
import sys
import os.path
import re

def up(resolvconf):
    new_resolv_contents = ''
    foreign_options = [value for (key,value) in os.environ.iteritems() if 'foreign_option' in key]
    for foreign_option in foreign_options:
        dns_servers = re.findall(r"DNS (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})", foreign_option)
        for dns_server in dns_servers:
            new_resolv_contents += "nameserver {}\n".format(dns_server)
    if new_resolv_contents:
        print("Writing the following to {}:\n{}".format(resolvconf, new_resolv_contents))
        with open(resolvconf, "w") as f:
            f.write(new_resolv_contents)
    else:
        print("Nothing to write to {}".format(resolvconf))

def down(resolv_conf, resolvconf_before):
    # Copying over does not work
    with open(resolvconf_before, 'r') as resolvconf_before_fh:
        with open(resolvconf, 'w') as resolvconf_fh:
            contents = resolvconf_before_fh.read()
            print("Writing the following to {}:\n{}".format(resolvconf, contents))
            resolvconf_fh.write(contents)

if __name__ == "__main__":
    resolvconf = '/etc/resolv.conf'
    # This is created by start_vpn.sh
    resolvconf_before = '/etc/resolv.conf.before_vpn'
    if 'script_type' not in os.environ.keys():
	print("Environment variable script_type is not set. Call this from openvpn.")
	sys.exit(1)
    if not os.path.isfile(resolvconf_before):
        print("Backup of resolv.conf is not in place: {}".format(resolvconf_before))
        sys.exit(1)
    script_type = os.environ['script_type']

    if script_type == 'up':
	up(resolvconf)
    elif script_type == 'down':
	down(resolvconf, resolvconf_before)
    else:
	print("ERROR: Unknown type {}".format(script_type))

