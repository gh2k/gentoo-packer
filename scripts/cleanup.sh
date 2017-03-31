#!/bin/bash

set -e
set -x

emerge sys-fs/zerofree

echo "Removing uneeded packages"

emerge --depclean

echo "Cleaning up portage and temporary files"

cd /usr/src/linux
make clean

rm -rf /usr/portage
rm -rf /var/tmp/*
rm -rf /root/*

echo "Cleaning the boot volume"

zerofree /dev/sda1

echo "Cleaning swap space"

swapoff /dev/sda2
dd if=/dev/zero of=/dev/sda2 bs=16M || echo Finished
mkswap /dev/sda2

echo "Remounting root filesystem read-only"

systemctl stop hv_kvp_daemon.service
systemctl stop systemd-journald.socket
systemctl stop systemd-journald.service

mount -o remount,ro /

echo "Cleaning the root volume"

zerofree -v /dev/sda3
