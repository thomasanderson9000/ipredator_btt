#!/usr/bin/env python
import os
import os.path

from SimpleXMLRPCServer import SimpleXMLRPCServer
from SimpleXMLRPCServer import SimpleXMLRPCRequestHandler

def set_vpn_gateways(servers):
    vpn_server_file = os.environ['VPN_SERVER_FILE']
    if os.path.isfile(vpn_server_file):
	print("VPN servers already set.")
	return "Skipped setting vpn gateways"
    with open(vpn_server_file, 'w') as f:
	f.write("\n".join(servers))
    print("Wrote VPN server '{}' to {}\n".format(servers, vpn_server_file))
    return "Successfully wrote gateways"

# Create server
print("Starting xmlrpc server")
server = SimpleXMLRPCServer(("0.0.0.0", 80))
server.register_function(set_vpn_gateways)
server.serve_forever()
