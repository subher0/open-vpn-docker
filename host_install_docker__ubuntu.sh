#!/bin/bash
set -e

if [ -z "$USER_TO_ADD" ]
then
  echo "PROPERTY {USER_TO_ADD} WAS NOT SET. PLEASE SET A USER TO ADD TO A DOCKER GROUP"
  exit 1
fi

# INSTALLING DOCKER
echo "############ INSTALLING DOCKER ############"
# WAIT FOR USER TO REALIZE WHAT IS GOING TO HAPPEN
for i in {1..5}
do
  REMAINING_SECS=6
  let "REMAINING_SECS -= i"
  echo "############ ABOUT TO INSTALL DOCKER FROM SU IN $REMAINING_SECS s #############"
  sleep 1
done

echo "REMOVING PREVIOUS DOCKER..."
apt-get remove docker docker.io containerd runc

echo "UPDATING APT AND INSTALLING CURL..."
apt-get update
apt-get install curl

echo "INSTALLING DOCKER REPO..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "UPDATING APT AGAIN..."
apt-get update

echo "INSTALLING DOCKER..."
apt-get install docker-ce docker-ce-cli containerd.io

echo "RUNNING HELLO WORLD..."
docker run hello-world

echo "############## ADDING USER $USER_TO_ADD TO DOCKER USERS ###################"
usermod -aG docker $USER_TO_ADD

echo "############## INSTALLING DOCKER COMPOSE ####################"
curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
