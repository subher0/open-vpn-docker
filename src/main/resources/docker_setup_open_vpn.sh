#!/bin/bash
set -e

if [ -z "$SERVER_IP" ]
then
  echo "PROPERTY {SERVER_IP} WAS NOT SET. PLEASE SET A SERVER_IP!"
  exit 1
fi
echo "######### DOWNLOADING NECESSARY DEPENDENCIES #############"
wget -P /docker/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz
mkdir -p $CA_HOME
mkdir -p $SERVER_HOME
cp /docker/EasyRSA-3.0.4.tgz $CA_HOME
cp /docker/EasyRSA-3.0.4.tgz $SERVER_HOME


echo "###### CONFIGURING EASY RSA CA ######"
cd $CA_HOME
mkdir tmp
tar xvf ./EasyRSA-3.0.4.tgz
cd $CA_HOME/EasyRSA-3.0.4/
mv /docker/vars ./
./easyrsa init-pki
./easyrsa build-ca nopass << EOF
bukhach
EOF


echo "###### CONFIGURING EASY RSA SERVER ######"
cd $SERVER_HOME
mkdir tmp
tar xvf ./EasyRSA-3.0.4.tgz
cd $SERVER_HOME/EasyRSA-3.0.4/
./easyrsa init-pki
./easyrsa gen-req server nopass << EOF1

EOF1
sudo cp $SERVER_HOME/EasyRSA-3.0.4/pki/private/server.key /etc/openvpn/
cp $SERVER_HOME/EasyRSA-3.0.4/pki/reqs/server.req $CA_HOME/tmp


echo "######## BACK TO CA ##########"
cd $CA_HOME/EasyRSA-3.0.4
./easyrsa import-req $CA_HOME/tmp/server.req server
./easyrsa sign-req server server << EOF2
yes
EOF2
cp pki/issued/server.crt $SERVER_HOME/tmp
cp pki/ca.crt $SERVER_HOME/tmp

echo "######## BACK TO THE SERVER ##########"
cd $SERVER_HOME
sudo cp $SERVER_HOME/tmp/{server.crt,ca.crt} /etc/openvpn/
cd ./EasyRSA-3.0.4/
./easyrsa gen-dh
openvpn --genkey --secret ta.key
sudo cp $SERVER_HOME/EasyRSA-3.0.4/ta.key /etc/openvpn/
sudo cp $SERVER_HOME/EasyRSA-3.0.4/pki/dh.pem /etc/openvpn/
mkdir -p $SERVER_HOME/client-configs/keys
chmod -R 700 $SERVER_HOME/client-configs

CERTIFICATI_NAME="initial"
echo "########## GENERATING CERT AND KEY PAIR ###########"
cd $SERVER_HOME/EasyRSA-3.0.4
./easyrsa gen-req $CERTIFICATI_NAME nopass << EOF3

EOF3
cp pki/private/$CERTIFICATI_NAME.key $SERVER_HOME/client-configs/keys/
cp pki/reqs/$CERTIFICATI_NAME.req $CA_HOME/tmp

echo "############# SIGNING CERTIFICATE #################"
cd $CA_HOME/EasyRSA-3.0.4/
./easyrsa import-req $CA_HOME/tmp/$CERTIFICATI_NAME.req $CERTIFICATI_NAME
./easyrsa sign-req client $CERTIFICATI_NAME << EOF4
yes
EOF4
cp ./pki/issued/$CERTIFICATI_NAME.crt $SERVER_HOME/tmp


echo "############# ADDING SIGNED KEY TO SERVER ###############"
cd $SERVER_HOME
cp $SERVER_HOME/tmp/$CERTIFICATI_NAME.crt $SERVER_HOME/client-configs/keys/
cp $SERVER_HOME/EasyRSA-3.0.4/ta.key $SERVER_HOME/client-configs/keys/
sudo cp /etc/openvpn/ca.crt $SERVER_HOME/client-configs/keys/

echo "####### CONFIGURING OpenVPN ########"
sudo cp /docker/openvpn-server.conf /etc/openvpn/server.conf
echo "net.ipv4.ip_forward=1" >> sudo tee -a /etc/sysctl.conf > /dev/null
sudo sysctl -p

echo "########## CONFIGURING CLIENT KEY DIRECTORIES #########"
mkdir -p $SERVER_HOME/client-configs/files
cp /docker/openvpn-client.conf $SERVER_HOME/client-configs/base.conf
sed -i -e "s/SERVER_IP_PLACEHOLDER/$SERVER_IP/g" $SERVER_HOME/client-configs/base.conf

cd $SERVER_HOME/client-configs

echo "######## TROUBLE SHOOTING ########"
sudo mkdir -p /dev/net
sudo mknod /dev/net/tun c 10 200