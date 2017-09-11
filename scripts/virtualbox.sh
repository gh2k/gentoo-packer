#!/bin/bash

set -e
set -x

echo "app-emulation/virtualbox" > /etc/portage/package.accept_keywords/virtualbox
echo "app-emulation/virtualbox-modules" >> /etc/portage/package.accept_keywords/virtualbox

echo "app-emulation/virtualbox headless -qt5 -opengl" > /etc/portage/package.use/virtualbox

emerge app-emulation/virtualbox \
       app-emulation/virtualbox-modules \
       --autounmask-continue

usermod -aG vboxusers vagrant
