#!/usr/bin/bash

set -ouex pipefail

dnf5 -y -q copr enable ublue-os/akmods

# Fetch Kernel RPMS
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/"${AKMODS_FLAVOR}"-kernel:"$(rpm -E %fedora)"-"${KERNEL}" dir:/tmp/kernel-rpms
KERNEL_TARGZ=$(jq -r '.layers[].digest' < /tmp/kernel-rpms/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/kernel-rpms/"$KERNEL_TARGZ" -C /
mv /tmp/rpms/* /tmp/kernel-rpms/

if [[ -z "$(grep kernel-devel <<< $(rpm -qa))" ]]; then
    dnf5 -y install /tmp/kernel-rpms/kernel-devel-*.rpm
fi

# Fetch AKMODS RPMS
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods:"${AKMODS_FLAVOR}"-"$(rpm -E %fedora)"-"${KERNEL}" dir:/tmp/akmods
AKMODS_TARGZ=$(jq -r '.layers[].digest' < /tmp/akmods/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods/"$AKMODS_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods/

# Install RPMS
dnf5 -y install /tmp/akmods/kmods/*kvmfr*.rpm
