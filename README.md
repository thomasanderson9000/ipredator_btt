# Docker openvpn client Setup for IPredator VPN with Transmission Bittorrent 
Docker setup for [IPredator](https://ipredator.se/) VPN with [Transmission](https://www.transmissionbt.com/) Bittorrent client. Limits non-encrypted traffic to query for openvpn server.

## Prerequisites

I used the following docker and docker-compose versions. I recommend using these versions or newer.

* docker-compose version 1.6.2, build 4d72027
* Docker version 1.10.2, build c3959b1

## Setup and Run

I am using environment variable files for user defined values like username and password. The ./setup.py script will read in all defaults and allow you to override them. ./up.py will read in required environment variables created with setup.py and run docker-compose build && docker-compose up <opt args> for you.

```
./setup.py
./up.py
```

Once the VPN has connected successfully transmission-daemon will be launched. You can connect to it via http://docker_host:9091/transmission/web/.

## Notes

Similiar to https://github.com/dperson/transmission. This uses docker-compose and all images are in subdirectories. I also bind the rpc port and btt port to local and vpn interfaces to avoid leaking if the VPN is down. 

