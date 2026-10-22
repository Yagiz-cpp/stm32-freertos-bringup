#include "FreeRTOS.h"
#include "task.h"
#include "uart.h"

volatile unsigned int g_task1_count = 0;
volatile unsigned int g_task2_count = 0;

void vTask1(void *pvParameters)
{
    (void)pvParameters;
    for(;;)
    {
        uart_puts("Task1 calisti\r\n");
        g_task1_count++;
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

void vTask2(void *pvParameters)
{
    (void)pvParameters;
    for(;;)
    {
        uart_puts("Task2 calisti\r\n");
        g_task2_count++;
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}

/* Called by the kernel if a task overflows its stack. */
void vApplicationStackOverflowHook(TaskHandle_t xTask, char *pcTaskName)
{
    (void)xTask;
    (void)pcTaskName;
    for(;;);
}

/* Trap on a hard fault (wired in the vector table). */
void HardFault_Handler(void)
{
    for(;;);
}

int main(void)
{
    uart_init();

    xTaskCreate(vTask1, "Task1", 128, NULL, 1, NULL);
    xTaskCreate(vTask2, "Task2", 128, NULL, 1, NULL);

    vTaskStartScheduler();

    /* Only reached if there was not enough heap to start the scheduler. */
    for(;;);
}
