#!/bin/sh

set -eo pipefail

OVPN_DATA_VOLUME="server-stuff_openvpn-data"
CLIENT_NAME=$1

if ! docker volume inspect "$OVPN_DATA_VOLUME" >/dev/null 2>&1; then
    echo "Volume $OVPN_DATA_VOLUME not found"
    exit 1
fi

if [[ -z "$CLIENT_NAME" ]]; then
    echo "Usage: $0 [client-name]"
    exit 1
fi

if [[ -f "$CLIENT_NAME.ovpn" ]]; then
    echo "File $CLIENT_NAME.ovpn already exists"
    exit 1
fi

echo "Creating client $CLIENT_NAME"

docker run -v $OVPN_DATA_VOLUME:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full "$CLIENT_NAME" nopass

umask 600
docker run -v $OVPN_DATA_VOLUME:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient "$CLIENT_NAME" > "$CLIENT_NAME".ovpn

echo "Done"
