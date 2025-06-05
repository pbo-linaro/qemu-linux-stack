QEMU/Linux Stack
================

Build/Run Linux under QEMU.
Only podman and qemu-user-binfmt need to be installed.

Build is based on containers to ensure it can be reproduced on any machine.
Rootfs is derived from a container image.

```
# build system using:
./build.sh

# run system using:
./run.sh /path/to/qemu-system-aarch64
# exit QEMU with ctrl-a + x

# debug kernel using:
./debug.sh /path/to/qemu-system-aarch64

# to debug qemu itself:
./run.sh gdb --args /path/to/qemu-system-aarch64

# to create an archive containing the whole stack:
./build.sh
./archive_artifacts.sh stack.tar.gz

# boot a nested guest from vm with:
/host/guest.sh qemu-system-aarch64
```
