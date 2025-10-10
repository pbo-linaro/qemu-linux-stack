#!/usr/bin/env bash

set -euo pipefail
set -x

[ -v INIT ] || INIT=

lspci -vvv

# find device to connect
sys_tsm_connect=$(find /sys | grep tsm/connect)
[ -f "$sys_tsm_connect" ]
# /sys/devices/pci0000:00/0000:00:04.0/0000:01:00.0/tsm/connect -> 0000:01:00.0
dev=$(basename $(realpath $(dirname $sys_tsm_connect)/..))
echo $dev

# bind it to tsm
echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
echo vfio-pci > /sys/bus/pci/devices/$dev/driver_override
echo $dev > /sys/bus/pci/drivers_probe
echo tsm0 > /sys/bus/pci/devices/$dev/tsm/connect

# prepare nested guest commands
mkdir -p guest
mount /host/out/guest.ext4 guest
cat > guest/da_connect.sh << EOF
#!/usr/bin/env bash
set -euo pipefail
set -x

lspci -vvv

echo "unbind device"
echo 0000:00:00.0 > /sys/bus/pci/devices/0000:00:00.0/driver/unbind
sleep 2
echo "lock device"
echo tsm0 > /sys/bus/pci/devices/0000:00:00.0/tsm/lock
sleep 2
echo "set TDISP run state"
echo 1 > /sys/bus/pci/devices/0000:00:00.0/tsm/accept
sleep 2
echo "load driver"
echo 0000:00:00.0 > /sys/bus/pci/drivers_probe
sleep 10
EOF
chmod +x guest/da_connect.sh
umount guest
rmdir guest

INIT=${INIT:-/da_connect.sh}

guest_efi=/tmp/guest_efi.img
dd if=/dev/zero of=$guest_efi count=1 bs=256M
mformat -i $guest_efi ::
mcopy -i $guest_efi /host/out/Image ::
cat > /tmp/startup.nsh << EOF
fs0:
Image nokaslr root=/dev/vda rw init=/init -- $INIT
EOF
mcopy -i $guest_efi /tmp/startup.nsh ::
mdir -i $guest_efi

cd /host
./out/lkvm run \
    --realm \
    -m 256 \
    --kernel /host/out/Image \
    --disk /host/out/guest.ext4 \
    --iommufd-vdevice \
    --vfio-pci $dev \
    --params "root=/dev/vda rw init=/init -- $INIT"

rm -f $guest_efi /tmp/startup.nsh

# rebind pci device to ahci
echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
echo ahci > /sys/bus/pci/devices/$dev/driver_override
echo $dev > /sys/bus/pci/drivers_probe
