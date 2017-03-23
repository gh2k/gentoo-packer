# gentoo-packer

This packer config builds a minimal Gentoo configuration compatible with hyperv and virtualbox. The package will use the latest ~amd64 kernel (the latest GA version) and virtualbox modules.

There are two flavours. 'gentoo-minimal' just installs the bare minimum for Gentoo to work under Vagrant vbox/hyperv. 'gentoo-docker' adds the Docker engine and is a decent base image to run docker containers in, with the minimum of fuss. (The latest ~amd64 Docker is used, which will be the latest GA version of Docker.)

On hyperv this will build the hyperv daemons from the kernel sources, and includes systemd units to start them. hv_kvp_daemon is very important as it allows the host operating system to see the VM's IP address.

`/usr/portage` is removed during cleanup to save space, so you will need to run the following to obtain the latest Portage snapshot, if you want to install packages:

```
emerge-webrsync && emerge --sync
```

## Download Script

The php script `external/latest_gentoo.php` is a hacky workaround to provide a redirect to the latest minimal install CD and stage3 tarball, as Gentoo do not provide static links to the latest builds.

## TODO:

- Add support for other hypervisors
