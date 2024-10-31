#!/bin/sh

set -oeux pipefail

# alternatives cannot create symlinks on its own during a container build
ln -sf /usr/bin/ld.bfd /etc/alternatives/ld && ln -sf /etc/alternatives/ld /usr/bin/ld

# Required by podman machine to work but it is on libexec by default
ln -sf /usr/bin/virtiofsd /usr/libexec/virtiofsd
