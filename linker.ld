ENTRY(_start)

SECTIONS
{
    . = 1M;  /* Start at 1MB - typical kernel load address */

    .boot :
    {
        /* Multiboot header must be in first 8KB */
        *(.multiboot)
    }

    .text :
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.bss)
    }
}
