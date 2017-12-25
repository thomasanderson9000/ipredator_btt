#!/usr/bin/env python
from __future__ import print_function
from urllib2 import URLError
from time import sleep
import shifter
import argparse

parser = argparse.ArgumentParser(description='Toggle dht and pex on transmission when inactive')
parser.add_argument('--host', required=True, help="Transmission host")
parser.add_argument('--port', type=int, required=True, help="Transmission port")
parser.add_argument('--seconds', type=int, required=True, help="Seconds between toggle cycle")
args = parser.parse_args()

print("control_transmission.py --host {} --port {} --seconds {}".format(args.host, args.port, args.seconds))
client = shifter.Client(host=args.host, port=args.port)
seconds_between_cycle = args.seconds
last_state = None
while True:
    try:
        active_torrent_count = client.session.stats()[u'active_torrent_count']
        print("Active torrents: {}".format(active_torrent_count))
        if active_torrent_count:
            if last_state != 'active':
                print("Turning DHT and PEX: ON")
                client.session.set(pex_enabled=True)
                client.session.set(dht_enabled=True)
                last_state = 'active'
        else:
            if last_state != 'inactive':
                print("Turning DHT and PEX: OFF")
                client.session.set(pex_enabled=False)
                client.session.set(dht_enabled=False)
                last_state = 'inactive'
    except URLError as e:
        print("URL Error!")
    print("Waiting {} seconds to control transmission.".format(seconds_between_cycle))
    sleep(seconds_between_cycle)

