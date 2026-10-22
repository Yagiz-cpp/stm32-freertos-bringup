CC = arm-none-eabi-gcc

CFLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 \
         -Wall -g -O2 \
         -IFreeRTOS-Kernel/include \
         -IFreeRTOS-Kernel/portable/GCC/ARM_CM4F \
         -Isrc


LDFLAGS = -T stm32l476rg.ld -nostartfiles --specs=nosys.specs

SRCS = src/main.c \
       src/uart.c \
       FreeRTOS-Kernel/tasks.c \
       FreeRTOS-Kernel/list.c \
       FreeRTOS-Kernel/queue.c \
       FreeRTOS-Kernel/timers.c \
       FreeRTOS-Kernel/portable/GCC/ARM_CM4F/port.c \
       FreeRTOS-Kernel/portable/MemMang/heap_4.c \
       startup_stm32.s


all: freertos.bin

freertos.elf: $(SRCS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(SRCS) -o freertos.elf

freertos.bin: freertos.elf
	arm-none-eabi-objcopy -O binary freertos.elf freertos.bin

flash: freertos.bin
	st-flash write freertos.bin 0x08000000

clean:
	rm -f freertos.elf freertos.bin