/* ==========================================================================
 *  Copyright (c) 2026 Yağız Kesepara.
 *
 *  Minimal startup for STM32L476RG (Cortex-M4F), FreeRTOS-ready.
 *  Vector table + reset handler (.data copy, .bss zero) then main().
 * ==========================================================================
 */
    .syntax unified
    .cpu cortex-m4
    .thumb

/* ---- Vector table ---------------------------------------------------- */
    .section .isr_vector, "a", %progbits
    .global g_pfnVectors
    .type   g_pfnVectors, %object
g_pfnVectors:
    .word   _estack                 /* 0  Initial SP (from linker) */
    .word   Reset_Handler           /* 1  Reset */
    .word   Default_Handler         /* 2  NMI */
    .word   HardFault_Handler       /* 3  HardFault */
    .word   Default_Handler         /* 4  MemManage */
    .word   Default_Handler         /* 5  BusFault */
    .word   Default_Handler         /* 6  UsageFault */
    .word   0                       /* 7  Reserved */
    .word   0                       /* 8  Reserved */
    .word   0                       /* 9  Reserved */
    .word   0                       /* 10 Reserved */
    .word   vPortSVCHandler         /* 11 SVCall   (FreeRTOS) */
    .word   Default_Handler         /* 12 DebugMon */
    .word   0                       /* 13 Reserved */
    .word   xPortPendSVHandler      /* 14 PendSV   (FreeRTOS) */
    .word   xPortSysTickHandler     /* 15 SysTick  (FreeRTOS) */
    /* External interrupts -> Default_Handler */
    .rept   82
    .word   Default_Handler
    .endr

/* ---- Reset handler --------------------------------------------------- */
    .section .text.Reset_Handler
    .weak   Reset_Handler
    .type   Reset_Handler, %function
Reset_Handler:
    /* Copy .data from FLASH (_sidata) to RAM (_sdata.._edata) */
    ldr     r0, =_sdata
    ldr     r1, =_edata
    ldr     r2, =_sidata
copy_data:
    cmp     r0, r1
    bge     zero_bss
    ldr     r3, [r2], #4
    str     r3, [r0], #4
    b       copy_data

    /* Zero the .bss section (_sbss.._ebss) */
zero_bss:
    ldr     r0, =_sbss
    ldr     r1, =_ebss
    movs    r2, #0
bss_loop:
    cmp     r0, r1
    bge     start_main
    str     r2, [r0], #4
    b       bss_loop

start_main:
    bl      main
    b       .                       /* main should never return */

/* ---- Default handler (trap) ------------------------------------------ */
    .section .text.Default_Handler
    .weak   Default_Handler
    .type   Default_Handler, %function
Default_Handler:
    b       .

    .end
