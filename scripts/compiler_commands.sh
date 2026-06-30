#!/bin/bash

riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -O0 -Ttext=0x00000000 -e main main.c -o main.elf

riscv32-unknown-elf-objcopy -O binary main.elf main.bin

hexdump -v -e '1/4 "%08x\n"' main.bin > program.hex


