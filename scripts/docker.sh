#!/bin/bash

set -e
set -x

echo "app-emulation/docker ~amd64" > /etc/portage/package.accept_keywords/docker
echo "app-emulation/docker overlay -device-mapper" > /etc/portage/package.use/docker

emerge app-emulation/docker

systemctl enable docker.service
usermod -aG docker vagrant
