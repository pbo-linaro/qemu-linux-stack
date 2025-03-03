QEMU/Linux Stack
================

Build/Run QEMU/Linux using a container.

```
# build system using:
./container.sh ./build.sh

# run system using (spawn gdb controlling kernel):
./run.sh /path/to/qemu-system-aarch64

# to debug qemu itself:
./run.sh gdb --args /path/to/qemu-system-aarch64
```
