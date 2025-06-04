QEMU/Linux Stack
================

Build/Run QEMU/Linux using containers.
You need to have podman and qemu-user-binfmt installed.

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
```
