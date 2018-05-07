#!/bin/bash

/change_transmission_uid_gid.sh
chown transmission:transmission ./.config
python -u ./healthcheck.py &
exec gosu transmission python -u ./drive.py
