#!/usr/bin/env python
from __future__ import print_function
from time import sleep
from subprocess import call
import os
from drive import get_active_torrents_count, get_vpn_ip, WAIT_CYCLE

MAX_FAIL=2

def transmission_down():
    try:
        _ = get_active_torrents_count()
        return False
    except Exception as exc:
        print("Problem getting active torrent count: {}".format(exc))
    return True

def vpn_down():
    try:
        _ = get_vpn_ip()
        return False
    except Exception as exc:
        print("Problem getting vpn IP: {}".format(exc))
    return True

def suicide():
    """Kill tini which will cause everything to restart properly."""
    print("Something went wrong, comitting suicide.")
    call("pkill -f tini", shell=True)

if __name__ == "__main__":
    fail_count = 0
    while True:
        sleep(WAIT_CYCLE)
        print("Health checking...")
        if transmission_down() or vpn_down():
            fail_count += 1
            print("Fail count: {}".format(fail_count))
        else:
            fail_count = 0
        if fail_count >= MAX_FAIL:
            suicide()


