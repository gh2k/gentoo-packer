#!/bin/bash

set -e
set -x

echo "app-emulation/docker ~amd64" > /etc/portage/package.accept_keywords/docker
echo "app-emulation/docker overlay -device-mapper" > /etc/portage/package.use/docker

emerge app-emulation/docker
emerge net-misc/bridge-utils

systemctl enable docker.service
usermod -aG docker vagrant

mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF > /etc/systemd/system/docker.service.d/tcp_listen.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
EOF
