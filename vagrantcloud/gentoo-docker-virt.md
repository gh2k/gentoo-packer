# gentoo-docker-virt

This is a minimal Docker install for vmware, virtualbox and hyperv, based on Gentoo and systemd. Guest tools are installed and the kernel is optimised for running as a VM guest.

VMWare and Virtualbox host software is also installed, but require VT-x extensions to work properly.

This is a rolling release, and the kernel for the current Docker build is `{{docker_version}}`. The kernel build is `{{kernel_version}}`.

`/usr/portage` is removed during cleanup to save space, so you will need to run the following to obtain the latest Portage snapshot if you want to install packages:

```
emerge-webrsync && emerge --sync
```

See https://github.com/symbols-worldwide/gentoo-packer/