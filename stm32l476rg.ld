/*
 * stm32l476rg.ld
 * FLASH linker script for STM32L476RG.
 * FLASH @ 0x08000000 (1 MB), SRAM1 @ 0x20000000 (96 KB).
 */

ENTRY(Reset_Handler)

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 1024K
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 96K
}

/* Top of stack = end of RAM (Cortex-M stack grows downward) */
_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
    /* Code + constants -> FLASH; vector table first */
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text*)
        *(.rodata*)
        . = ALIGN(4);
        _etext = .;
    } > FLASH

    /* Initialized data: lives in RAM, stored in FLASH, copied at reset */
    _sidata = LOADADDR(.data);

    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM AT > FLASH

    /* Zero-initialized data -> RAM, cleared at reset */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > RAM
}
