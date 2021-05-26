#!/bin/bash

if [ "x$2" == "x" ]; then
  echo "Usage: $0 [provisioner] [build-config]" >&2
  exit 1
fi

ISO_BASE=$(curl http://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/latest-install-amd64-minimal.txt | egrep -v '^#' | sed 's/ .*//')
STAGE3_BASE=$(curl http://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt | egrep -v '^#' | sed 's/ .*//')

ISO_URL=http://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/$ISO_BASE
STAGE3_URL=http://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/$STAGE3_BASE
CHECKSUM_URL=$ISO_URL.DIGESTS.asc

packer build --only=$1-iso --var isourl=$ISO_URL --var checksumurl=$CHECKSUM_URL --var stage3url=$STAGE3_URL --var outfile=boxen/$2-$1.box --var headless=true $2.json
