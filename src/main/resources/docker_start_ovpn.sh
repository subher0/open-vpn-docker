#!/bin/bash
echo "######## CREATING NET DIRS ########"
mkdir -p /dev/net
mknod /dev/net/tun c 10 200

cd /etc/openvpn
openvpn --config server.conf