#!/bin/bash

set -x
set -e

echo "Installing network filesystem tools"

# don't compile in Active Directory support, it pulls in lots of deps
echo "net-fs/cifs-utils -acl -ads" > /etc/portage/package.use/cifs

emerge nfs-utils cifs-utils 
