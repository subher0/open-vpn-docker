#!/bin/bash
set -e

if [ -z "$SERVER_IP" ]
then
  echo "PROPERTY {SERVER_IP} WAS NOT SET. PLEASE SET A SERVER_IP!"
  exit 1
fi

echo "######### DOWNLOADING NECESSARY DEPENDENCIES #############"
mkdir -p $CA_HOME
mkdir -p $SERVER_HOME
cp /docker/EasyRSA-3.2.2.tgz $CA_HOME
cp /docker/EasyRSA-3.2.2.tgz $SERVER_HOME


echo "###### CONFIGURING EASY RSA CA ######"
cd $CA_HOME
mkdir tmp
tar xvf ./EasyRSA-3.2.2.tgz
cd $CA_HOME/EasyRSA-3.2.2/
mv /docker/vars ./
./easyrsa init-pki
./easyrsa build-ca nopass << EOF
bukhach
EOF


echo "###### CONFIGURING EASY RSA SERVER ######"
cd $SERVER_HOME
mkdir tmp
tar xvf ./EasyRSA-3.2.2.tgz
cd $SERVER_HOME/EasyRSA-3.2.2/
./easyrsa init-pki
./easyrsa gen-req server nopass << EOF1

EOF1
cp $SERVER_HOME/EasyRSA-3.2.2/pki/private/server.key /etc/openvpn/
cp $SERVER_HOME/EasyRSA-3.2.2/pki/reqs/server.req $CA_HOME/tmp


echo "######## BACK TO CA ##########"
cd $CA_HOME/EasyRSA-3.2.2
./easyrsa import-req $CA_HOME/tmp/server.req server
./easyrsa sign-req server server << EOF2
yes
EOF2
cp pki/issued/server.crt $SERVER_HOME/tmp
cp pki/ca.crt $SERVER_HOME/tmp

echo "######## BACK TO THE SERVER ##########"
cd $SERVER_HOME
cp $SERVER_HOME/tmp/{server.crt,ca.crt} /etc/openvpn/
cd ./EasyRSA-3.2.2/
./easyrsa gen-dh
openvpn --genkey --secret ta.key
cp $SERVER_HOME/EasyRSA-3.2.2/ta.key /etc/openvpn/
cp $SERVER_HOME/EasyRSA-3.2.2/pki/dh.pem /etc/openvpn/
mkdir -p $SERVER_HOME/client-configs/keys
chmod -R 700 $SERVER_HOME/client-configs

CERTIFICATI_NAME="initial"
echo "########## GENERATING CERT AND KEY PAIR ###########"
cd $SERVER_HOME/EasyRSA-3.2.2
./easyrsa gen-req $CERTIFICATI_NAME nopass << EOF3

EOF3
cp pki/private/$CERTIFICATI_NAME.key $SERVER_HOME/client-configs/keys/
cp pki/reqs/$CERTIFICATI_NAME.req $CA_HOME/tmp

echo "############# SIGNING CERTIFICATE #################"
cd $CA_HOME/EasyRSA-3.2.2/
./easyrsa import-req $CA_HOME/tmp/$CERTIFICATI_NAME.req $CERTIFICATI_NAME
./easyrsa sign-req client $CERTIFICATI_NAME << EOF4
yes
EOF4
cp ./pki/issued/$CERTIFICATI_NAME.crt $SERVER_HOME/tmp


echo "############# ADDING SIGNED KEY TO SERVER ###############"
cd $SERVER_HOME
cp $SERVER_HOME/tmp/$CERTIFICATI_NAME.crt $SERVER_HOME/client-configs/keys/
cp $SERVER_HOME/EasyRSA-3.2.2/ta.key $SERVER_HOME/client-configs/keys/
cp /etc/openvpn/ca.crt $SERVER_HOME/client-configs/keys/

echo "####### CONFIGURING OpenVPN ########"
cp /docker/openvpn-server.conf /etc/openvpn/server.conf
echo "net.ipv4.ip_forward=1" >> tee -a /etc/sysctl.conf > /dev/null
sysctl -p