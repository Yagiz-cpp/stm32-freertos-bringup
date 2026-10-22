#include "FreeRTOS.h"
#include "task.h"
#include <time.h>
#include "uart.h"

volatile unsigned int g_task1_count = 0;
volatile unsigned int g_task2_count = 0;

void vTask1(void *pvParameters)
{
    for(;;)
    {
        uart_puts("Task1 calisti\r\n");
        g_task1_count++;
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

void vTask2(void *pvParameters)
{
    for(;;)
    {
        uart_puts("Task2 calisti\r\n");
        g_task2_count++;
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}

void vApplicationStackOverflowHook(TaskHandle_t xTask, char *pcTaskName)
{
    (void)xTask;
    (void)pcTaskName;
    for(;;);
}

void vAssertCalled(const char *pcFile, unsigned int ulLine)
{
    uart_puts("ASSERT ");
    uart_puts(pcFile);
    uart_puts(":");
    uart_put_num(ulLine);
    uart_puts("\r\n");
    taskDISABLE_INTERRUPTS();
    for(;;);
}

void HardFault_Handler()
{
    uart_puts("HARDFAULT\r\n");
}
int main()
{

    uart_init();
    uart_puts("BOOT\r\n");

    xTaskCreate(vTask1, "Task1", 128, NULL, 1, NULL);
    xTaskCreate(vTask2, "Task2", 128, NULL, 1, NULL);
    
    vTaskStartScheduler();

    uart_puts("SCHED RETURNED\r\n");
    for(;;);
}

