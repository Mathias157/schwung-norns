#!/bin/sh
# Complete the privileged part of a Schwung Store installation.
set -eu

MODULE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CHROOT="/data/UserData/pw-chroot"
SCHWUNG_BIN="/data/UserData/schwung/bin"
RNBO_DIR="/data/UserData/rnbo"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: run this bootstrap as root." >&2
    echo "ssh root@move.local 'sh $MODULE_DIR/bootstrap-norns.sh'" >&2
    exit 1
fi

if [ ! -x "$RNBO_DIR/bin/jackd" ]; then
    echo "ERROR: RNBO Takeover for Move is not installed." >&2
    echo "Install RNBO first, then run this command again." >&2
    exit 1
fi

if [ ! -d "$CHROOT/usr" ]; then
    echo "ERROR: the Norns Debian chroot is not installed at $CHROOT." >&2
    echo "Run quickinstall-norns.sh from this repository once, then retry." >&2
    exit 1
fi

if [ ! -x "$MODULE_DIR/bin/pw-helper" ] || [ ! -x "$MODULE_DIR/bin/norns-input-bridge" ]; then
    echo "ERROR: this Norns package is incomplete. Reinstall it from the Store." >&2
    exit 1
fi

echo "Installing the Norns privileged helper..."
mkdir -p "$SCHWUNG_BIN"
cp "$MODULE_DIR/bin/pw-helper" "$SCHWUNG_BIN/pw-helper-norns"
chown root:root "$SCHWUNG_BIN/pw-helper-norns"
chmod 4755 "$SCHWUNG_BIN/pw-helper-norns"

echo "Installing the Norns input bridge..."
mkdir -p "$CHROOT/usr/local/bin"
cp "$MODULE_DIR/bin/norns-input-bridge" "$CHROOT/usr/local/bin/norns-input-bridge"
chmod 755 "$CHROOT/usr/local/bin/norns-input-bridge"

mkdir -p "$CHROOT/etc/profile.d"
cat > "$CHROOT/etc/profile.d/jack.sh" << 'PROFILE'
# Auto-set JACK environment for Move.
export XDG_RUNTIME_DIR=/tmp/pw-runtime-1
PROFILE
chmod 644 "$CHROOT/etc/profile.d/jack.sh"
rm -f "$CHROOT/etc/profile.d/pipewire.sh"

if [ ! -x "$CHROOT/home/we/norns/build/matron/matron" ]; then
    echo "Installing the Norns runtime. This can take 10-30 minutes..."
    sh "$MODULE_DIR/scripts/setup-norns.sh"
else
    echo "Norns runtime already installed; keeping the existing chroot data."
fi

echo ""
echo "Norns bootstrap complete. Restart Schwung, then open Norns from Tools."
