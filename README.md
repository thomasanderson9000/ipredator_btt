# Docker Setup for IPredator VPN with Transmission Bittorrent 
Docker setup for [IPredator](https://ipredator.se/) VPN with Transmission Bittorrent

## Setup and Run

```
./setup.py
./up.py
```

Similiar to https://github.com/dperson/transmission with some differences. This uses docker-compose and all images are in subdirectories. I also bind the rpc port and btt port to local and vpn interfaces to avoid leaking if the VPN is down. 

I built this using:
docker-compose version 1.6.2, build 4d72027
Docker version 1.10.2, build c3959b1
