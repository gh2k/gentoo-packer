#!/bin/bash

set -e
set -x

# clone vmware repository
mkdir -p /usr/local/portage/vmware
wget https://gitweb.gentoo.org/proj/vmware.git/snapshot/master.tar.gz -O- | tar xz -C /usr/local/portage/vmware --strip-components 1

echo 'PORTDIR_OVERLAY="/usr/local/portage/vmware"' >> /etc/portage/make.conf

echo "app-emulation/vmware-workstation ~amd64" > /etc/portage/package.accept_keywords/vmware
echo "app-emulation/vmware-modules ~amd64" >> /etc/portage/package.accept_keywords/vmware
echo "app-emulation/vmware-workstation::vmware" >> /etc/portage/package.unmask
echo "app-emulation/vmware-modules::vmware" >> /etc/portage/package.unmask

# we have to install X, even if we're not going to use it,
# because we can't just install the modules by themselves and there's no headless version

echo "x11-libs/cairo aqua X" > /etc/portage/package.use/vmware
echo "dev-cpp/cairomm aqua X" >> /etc/portage/package.use/vmware
echo "app-emulation/vmware-workstation server bundled-libs" >> /etc/portage/package.use/vmware

emerge app-emulation/vmware-workstation \
       app-emulation/vmware-modules \
       --autounmask-continue

emerge --config vmware-workstation

systemctl enable vmware.target

