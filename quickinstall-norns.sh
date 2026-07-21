#!/usr/bin/env bash
set -euo pipefail

DEVICE_HOST="${DEVICE_HOST:-move.local}"
NORNS_VERSION="0.4.3"
CHROOT_VERSION="0.2.0"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/schwung-norns.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

cd "$WORK_DIR"

git clone --depth 1 https://github.com/djhardrich/schwung-norns
git clone --depth 1 https://github.com/djhardrich/schwung-chroot-linux

mkdir -p schwung-norns/dist schwung-chroot-linux/dist

curl -fL -o schwung-norns/dist/norns-module.tar.gz \
    "https://github.com/djhardrich/schwung-norns/releases/download/v${NORNS_VERSION}/norns-module.tar.gz"
curl -fL -o schwung-chroot-linux/dist/pipewire-module.tar.gz \
    "https://github.com/djhardrich/schwung-chroot-linux/releases/download/v${CHROOT_VERSION}/pipewire-module.tar.gz"
curl -fL -o schwung-chroot-linux/dist/pw-chroot-desktop.tar.gz \
    "https://github.com/djhardrich/schwung-chroot-linux/releases/download/v${CHROOT_VERSION}/pw-chroot-desktop.tar.gz"

# The chroot installer expects the PipeWire module directory, not just its
# release archive.
tar -xzf schwung-chroot-linux/dist/pipewire-module.tar.gz \
    -C schwung-chroot-linux/dist

# schwung-chroot-linux v0.2.0 copies support files into the chroot before it
# extracts a fresh rootfs. Seed the rootfs first so a clean install cannot be
# mistaken for an existing chroot after those directories are created.
if ! ssh "root@$DEVICE_HOST" '[ -d /data/UserData/pw-chroot/usr ]'; then
    echo "Installing the Norns Linux environment (about 384 MB)..."
    scp schwung-chroot-linux/dist/pw-chroot-desktop.tar.gz \
        "root@$DEVICE_HOST:/data/pw-chroot.tar.gz"
    ssh "root@$DEVICE_HOST" \
        'mkdir -p /data/UserData/pw-chroot && cd /data/UserData/pw-chroot && tar -xzf /data/pw-chroot.tar.gz && rm -f /data/pw-chroot.tar.gz'
fi

cd schwung-chroot-linux && DEVICE_HOST="$DEVICE_HOST" ./scripts/install.sh
cd ../schwung-norns && DEVICE_HOST="$DEVICE_HOST" ./scripts/install.sh

ssh "root@$DEVICE_HOST" 'sh /data/setup-norns.sh'
