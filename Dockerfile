FROM ubuntu:18.04

RUN apt-get update && apt-get install -y expect openvpn tar sed iptables openssl

RUN mkdir -p /docker/scripts
COPY scripts/docker /docker/scripts
COPY conf/openvpn /docker

ENV CA_HOME /docker/ca
ENV SERVER_HOME /docker/server
ENV PATH $PATH:/docker/scripts
ENV SERVER_IP 0.0.0.0

ADD https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz /docker
RUN ["chmod", "-R", "+x", "/docker/scripts/"]

RUN /docker/scripts/docker_setup_open_vpn.sh
RUN /docker/scripts/docker_generate_cert.sh initial

WORKDIR /etc/openvpn

ENTRYPOINT ["/docker/scripts/docker_start_ovpn.sh"]