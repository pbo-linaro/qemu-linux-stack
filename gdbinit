set remotetimeout 99999
target remote :1234

add-symbol-file ./arm-trusted-firmware/build/qemu/debug/bl1/bl1.elf
b bl1_main
add-symbol-file ./arm-trusted-firmware/build/qemu/debug/bl2/bl2.elf
b bl2_main
add-symbol-file ./arm-trusted-firmware/build/qemu/debug/bl31/bl31.elf
b bl31_main
add-symbol-file ./linux/vmlinux
b start_kernel

c
