MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 256
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 256
}

SECTIONS
{
    .text : {
        *(.text)
        *(.text*)
    } > ROM

    .data : { *(.data) } > RAM
    .bss  : { *(.bss)  } > RAM
}
