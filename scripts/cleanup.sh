#!/bin/bash

set -e
set -x

emerge sys-fs/zerofree sys-fs/shake

echo "Removing uneeded packages"

emerge --depclean

echo "Cleaning up portage and temporary files"

cd /usr/src/linux
make clean

rm -rf /usr/portage
rm -rf /var/tmp/*
rm -rf /root/*

echo "Defragmenting root filesystem"

shake / > /dev/null 2>&1

echo "Rebooting with read-only file system"

# remount the root fs read-only
# we do it this way because stopping services has proven to be fairly unreliable

sed -i 's/noatime    0 1/noatime,ro 0 1/' /etc/fstab
systemctl reboot

# sleep until we get kicked out by systemd, so packer doesn't reconnect before
# we're ready

sleep 600

