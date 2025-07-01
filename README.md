QEMU/Linux Stack
================

Build/Run Linux under QEMU.
Only podman and qemu-user-binfmt need to be installed.

Build is based on containers to ensure it can be reproduced on any machine.
Rootfs is derived from a container image.

A custom Linux kernel can be built instead by creating a symlink named linux.

```
# build system using:
./build.sh

# run system using:
./run.sh /path/to/qemu-system-aarch64
# exit QEMU with ctrl-a + x

# debug kernel and firmwares using:
./debug.sh /path/to/qemu-system-aarch64
# additional gdb commands were added, like arm-exception-level. See gdb.py.

# to debug qemu itself:
./run.sh gdb --args /path/to/qemu-system-aarch64

# to create an archive containing the whole stack:
./build.sh
./archive_artifacts.sh stack.tar.xz
```

It's possible to automate execution of commands in the VM:

```
# Current working directory is mounted as /host in VM
# A script named guest.sh can be used to launch a nested guest
# Finally, a custom command can be passed to init script using INIT env var

# To boot a nested guest, and call hostname:
INIT='env INIT=hostname /host/guest.sh qemu-system-aarch64' ./run.sh qemu-system-aarch64

# In case command fail, init will trigger a Kernel panic
INIT='false' ./run.sh qemu-system-aarch64
```
