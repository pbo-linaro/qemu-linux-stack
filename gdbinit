set remotetimeout 99999
target remote :1234

source ./gdb.py

add-symbol-file ./arm-trusted-firmware/build/qemu_sbsa/release/bl1/bl1.elf
b bl1_main
add-symbol-file ./arm-trusted-firmware/build/qemu_sbsa/release/bl2/bl2.elf
b bl2_main
add-symbol-file ./arm-trusted-firmware/build/qemu_sbsa/release/bl31/bl31.elf
b bl31_main

# For rmm, we need to find loaded address (chosen by TF-A) + offset (build)
# Check for RMM address loaded by TF-A:
# $ ./run.sh qemu-system-aarch64 | grep 'Reserved RMM memory'
# INFO:    Reserved RMM memory [0x10000000000, 0x10042ffffff] in Device tree
# Check for offset in RMM image:
# ./build_rmm.sh |& grep 'offset of the RMM core'
# 0x20000
add-symbol-file ./tf-rmm/build/Release/rmm.elf 0x10000020000
b rmm_main

add-symbol-file ./linux/vmlinux
b start_kernel

c
