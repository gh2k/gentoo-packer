#!/bin/bash

set -e
set -x

echo "Cleaning the boot volume"

zerofree /dev/sda1

echo "Cleaning swap space"

swapoff /dev/sda2
dd if=/dev/zero of=/dev/sda2 bs=16M || echo Finished
mkswap /dev/sda2

echo "Zero-freeing root filesystem"
zerofree /dev/sda3
mount -o remount,rw /
sed -i 's/,ro/   /' /etc/fstab

rm /etc/machine-id
touch /etc/machine-id
