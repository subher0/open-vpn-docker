FROM ubuntu:24.04
ARG SERVER_IP

RUN apt-get update && apt-get install -y openvpn tar sed iptables openssl

RUN mkdir -p /docker/scripts
COPY scripts/docker /docker/scripts
COPY conf/openvpn /docker

ENV CA_HOME /docker/ca
ENV SERVER_HOME /docker/server
ENV PATH $PATH:/docker/scripts
ENV SERVER_IP $SERVER_IP

ADD https://github.com/OpenVPN/easy-rsa/releases/download/v3.2.2/EasyRSA-3.2.2.tgz /docker
RUN ["chmod", "-R", "+x", "/docker/scripts/"]

RUN /docker/scripts/docker_setup_open_vpn.sh

WORKDIR /etc/openvpn

ENTRYPOINT ["/docker/scripts/docker_start_ovpn.sh"]