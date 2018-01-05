#!/bin/bash

set -e
set -x

# Grab the latest portage
echo "Syncing Portage"
emerge-webrsync && emerge --sync --quiet

# Set the portage profile
eselect profile set default/linux/amd64/17.0/systemd
. /etc/profile

# Install updates
echo "Updating system"
emerge -uDN @world

# Set the system locale
echo "Setting locale"
locale-gen
eselect locale set "en_GB.utf8"

. /etc/profile

# Grab the kernel sources
echo "Installing kernel source"
emerge sys-kernel/gentoo-sources

# Install kernel build tools and configure
echo "Preparing to build kernel"

emerge sys-kernel/genkernel-next sys-boot/grub sys-fs/fuse sys-apps/dmidecode

if [ "$(dmidecode -s system-manufacturer)" == "Microsoft Corporation" ]; then
  # Ensure hyperv modules are loaded at boot, and included in the initramfs
  echo 'MODULES_HYPERV="hv_vmbus hv_storvsc hv_balloon hv_netvsc hv_utils"' >> /usr/share/genkernel/arch/x86_64/modules_load
  echo 'modules="hv_storvsc hv_netvsc hv_vmbus hv_utils hv_balloon"' >> /etc/conf.d/modules
  sed -ri "s/(HWOPTS='.*)'/\1 hyperv'/" /usr/share/genkernel/defaults/initrd.defaults
fi

# Build the kernel with genkernel
echo "Building the kernel"

genkernel --kernel-config=/etc/kernels/kernel_config --makeopts=-j5 all

# Build & install the VM tools

# If we're running on hyper-v, enable the tools
if [ "$(dmidecode -s system-manufacturer)" == "Microsoft Corporation" ]; then
  # kernel modules are already built in the kernel
  cd /usr/src/linux/tools/hv
  make
  cp hv_fcopy_daemon hv_vss_daemon hv_kvp_daemon /usr/sbin

  systemctl enable hv_fcopy_daemon.service
  systemctl enable hv_vss_daemon.service
  systemctl enable hv_kvp_daemon.service
elif [ "$(dmidecode -s system-product-name)" == "VirtualBox" ]; then
  # Install VirtualBox from portage
  echo "app-emulation/virtualbox-guest-additions ~amd64" > /etc/portage/package.accept_keywords/virtualbox
  emerge app-emulation/virtualbox-guest-additions

  systemctl enable virtualbox-guest-additions.service
elif [ "$(dmidecode -s system-product-name)" == "VMware Virtual Platform" ]; then
  echo "app-emulation/open-vm-tools ~amd64" > /etc/portage/package.accept_keywords/vmware
  emerge app-emulation/open-vm-tools

  systemctl enable vmtoolsd
else
  echo "Unknown hypervisor! :(" 1>&2
  exit 1
fi

# Set up the things we need for a base system
echo "Configuring up the base system"

# sudo and cron
echo "app-admin/sudo -sendmail" > /etc/portage/package.use/sudo
emerge sys-process/cronie app-admin/sudo

# systemd setup and hostname
systemd-machine-id-setup  --commit # remember to remove this before packaging the box
echo "gentoo-minimal" > /etc/hostname
echo "127.0.1.1 gentoo-minimal.local gentoo-minimal" >> /etc/hosts

# networking
cat > /etc/systemd/network/50-dhcp.network <<EOT
[Match]
Name=eth0

[Network]
DHCP=yes

[DHCP]
ClientIdentifier=mac
EOT

systemctl enable systemd-networkd.service

# ssh
systemctl enable sshd.service
echo "UseDNS no" >> /etc/ssh/sshd_config

yes YES | etc-update --automode -9

# Create the vagrant user with the vagrant public key
echo "Creating Vagrant user"

date > /etc/vagrant_box_build_time

useradd -s /bin/bash -m vagrant
echo -e "vagrant\nvagrant" | passwd vagrant

mkdir -pm 700 /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys \
  'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Install grub and hope everything is ready!
echo "Installing bootloader"

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "Installing additional tools"
emerge @tools

echo "Updating resolv.conf"

rm /etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl enable systemd-resolved.service

echo "Removing provision script"
rm /root/provision_gentoo_chroot.sh
