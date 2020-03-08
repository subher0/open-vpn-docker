## An easy openvpn installation inside a docker
## ToDo
1. Install docker (there is a script for ubuntu hosts host_isntall_docker__ubuntu.sh)
2. run `docker-compose up --build` to build the image and run the container. <b>Note: There has to be an env variable SERVER_IP on the host, containing a server Ip
3. [Optional] Configure UFW if necessary (conf/UFW and conf/UFW-before.rules)
4. There is going to be a key in /etc/openvpn_clients/files/initial.ovpn. Use it to connect from a client
5. [Optional] To generate more keys bash to docker and run /docker/scripts/docker_generated_cert.sh <client_name> 
### Note: Majority of cryptography is done during build time, so keep this in mind.