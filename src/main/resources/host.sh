#!/bin/sh
set -e

docker build -t bukhach/openvpn .
docker-compose up