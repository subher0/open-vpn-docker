#!/bin/bash
set -e

CERTIFICATI_NAME=${1}
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

KEY_DIR=$SERVER_HOME/client-configs/keys
OUTPUT_DIR=$SERVER_HOME/client-configs/files
BASE_CONFIG=$SERVER_HOME/client-configs/base.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${1}.ovpn