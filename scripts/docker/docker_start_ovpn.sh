#!/bin/bash
echo "########## CONFIGURING CLIENT KEY DIRECTORIES #########"
mkdir -p $SERVER_HOME/client-configs/files
cp /docker/openvpn-client.conf $SERVER_HOME/client-configs/base.conf
cp $SERVER_HOME/EasyRSA-3.0.4/ta.key $SERVER_HOME/client-configs/keys/
cp /etc/openvpn/ca.crt $SERVER_HOME/client-configs/keys/
sed -i -e "s/SERVER_IP_PLACEHOLDER/$SERVER_IP/g" $SERVER_HOME/client-configs/base.conf

cd $SERVER_HOME/client-configs
/docker/scripts/docker_generate_cert.sh initial

echo "######## CREATING NET DIRS ########"
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

cd /etc/openvpn
openvpn --config server.conf