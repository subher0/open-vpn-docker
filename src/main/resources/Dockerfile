FROM ubuntu:18.04

RUN apt-get update && apt-get -y install sudo
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN apt-get install -y python3 expect openvpn wget tar sed iptables

RUN mkdir -p /docker/scripts
COPY docker_setup_open_vpn.sh /docker/scripts
COPY docker_generate_cert.sh /docker/scripts
COPY openvpn-server.conf /docker
COPY openvpn-client.conf /docker
COPY ./vars /docker
COPY ./endless.py /docker

ENV CA_HOME /docker/ca
ENV SERVER_HOME /docker/server
ENV PATH $PATH:/docker/scripts
ENV SERVER_IP 0.0.0.0

RUN ["chmod", "+x", "/docker/scripts/docker_setup_open_vpn.sh"]
RUN ["chmod", "+x", "/docker/scripts/docker_generate_cert.sh"]

RUN /docker/scripts/docker_setup_open_vpn.sh
#RUN cd $SERVER_HOME/client-configs
#RUN /docker/scripts/docker_generate_cert.sh pronconf

RUN python3 /docker/endless.py

#RUN openvpn