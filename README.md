# Bare-metal FreeRTOS on STM32L476RG

FreeRTOS brought up **by hand** on a NUCLEO-L476RG (Cortex-M4F), without CubeIDE
or the HAL. Everything from the vector table up: the startup code, the linker
layout, a register-level UART driver, and the FreeRTOS scheduler running two
periodic tasks on real silicon.

This is a learning project — the goal was to understand every layer, not to use
a framework that hides it.

## What's in here

| File | Purpose |
|------|---------|
| `startup_stm32.s` | Vector table + reset handler (`.data` copy, `.bss` zero), then `main()` |
| `stm32l476rg.ld` | Memory layout: FLASH @ `0x08000000`, RAM @ `0x20000000`, stack at top of RAM |
| `src/main.c` | Two FreeRTOS tasks + the scheduler |
| `src/uart.c`, `src/uart.h` | Bare-metal USART2 driver (PA2/PA3, AF7, 115200 baud) |
| `src/FreeRTOSConfig.h` | Kernel config (MSI 4 MHz, 1 kHz tick) |
| `Makefile` | Build + flash |

The vector table wires `SVC`/`PendSV`/`SysTick` to the FreeRTOS handlers, which
is what makes the scheduler and context switching work.

## Build & run

Requires the `arm-none-eabi` GCC toolchain, `stlink-tools`, and the FreeRTOS kernel.

```sh
# 1. Clone the FreeRTOS kernel next to the sources (it is gitignored here)
git clone https://github.com/FreeRTOS/FreeRTOS-Kernel.git

# 2. Build
make

# 3. Flash over ST-LINK
make flash

# 4. Watch the output on the ST-LINK virtual COM port
screen /dev/ttyACM0 115200
```

Expected output:

```
Task1 calisti
Task2 calisti
Task1 calisti
...
```

`Task1` runs every 500 ms, `Task2` every 1000 ms — the scheduler time-slices
the two tasks by priority and period.

## Target

STM32L476RG · ARM Cortex-M4F · 128 KB RAM · FreeRTOS (ARM_CM4F port, heap_4)
