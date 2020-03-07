#!/bin/sh
set -e

if [ -z "$USER_TO_ADD" ]
then
  echo "PROPERTY {USER_TO_ADD} WAS NOT SET. PLEASE SET A USER TO ADD TO A DOCKER GROUP"
  exit 1
fi

# INSTALLING DOCKER
echo "############ INSTALLING DOCKER ############"
sudo -s
# WAIT FOR USER TO REALIZE WHAT IS GOING TO HAPPEN
for i in {1..5}
do
  REMAINING_SECS=6
  let "REMAINING_SECS -= i"
  echo "############ ABOUT TO INSTALL DOCKER FROM SU IN $REMAINING_SECS s #############"
  sleep 1
done

apt-get remove docker docker-engine docker.io containerd runc
apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io
docker run hello-world

echo "############## ADDING USER $USER_TO_ADD TO DOCKER USERS ###################"
usermod -aG docker $USER_TO_ADD