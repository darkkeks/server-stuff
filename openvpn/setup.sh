#!/bin/sh

set -eo pipefail

OVPN_DATA_VOLUME="server-stuff_openvpn-data"
OVPN_ADDRESS="udp://h1.darkkeks.me"

if docker volume inspect "$OVPN_DATA_VOLUME" >/dev/null 2>&1; then
    read -p "Volume $OVPN_DATA_VOLUME already exists, remove it? [y/n]: " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing volume $OVPN_DATA_VOLUME"
        docker volume rm "$OVPN_DATA_VOLUME"
    else
        exit
    fi
fi

echo "Creating volume $OVPN_DATA_VOLUME"
docker volume create --name "$OVPN_DATA_VOLUME"

echo "Initialising volume with address $OVPN_ADDRESS"
docker run -v $OVPN_DATA_VOLUME:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u "$OVPN_ADDRESS"
docker run -v $OVPN_DATA_VOLUME:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

echo "Done"
