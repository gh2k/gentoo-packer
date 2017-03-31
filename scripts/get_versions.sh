#!/bin/bash

set -x

mkdir -p /tmp/versions

emerge app-portage/gentoolkit

equery -q l sys-kernel/gentoo-sources > /tmp/versions/gentoo-sources
equery -q l app-emulation/docker > /tmp/versions/docker

emerge -C app-portage/gentoolkit

exit 0
