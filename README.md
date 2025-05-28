QEMU/Linux Stack
================

Build/Run QEMU/Linux using a container.

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
```
