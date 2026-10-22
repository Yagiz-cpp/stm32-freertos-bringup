#include "uart.h"

#define REG(addr) (*(volatile unsigned int *)(addr))
#define RCC_AHB2ENR REG(0x4002104C)
#define RCC_APB1ENR1 REG(0x40021058)

#define GPIOA_MODER REG(0x48000000)
#define GPIOA_AFRL REG(0x48000020)

#define USART2_CR1 REG(0x40004400)
#define USART2_BRR REG(0x4000440C)

#define USART2_ISR REG(0x4000441C)
#define USART2_TDR REG(0x40004428)

void uart_init(void)
{
    // 1-) Clock: openings
    RCC_AHB2ENR |= (1 << 0); // GPIOAEN : GPIOA port clock 
    RCC_APB1ENR1 |= (1 << 17); // USART2EN : USART2 clock

    // 2-) Pin Modes : Alternate Function Mode
    GPIOA_MODER &= ~((3 << 4) | (3 << 6));
    GPIOA_MODER |= ((2 << 4) | (2 << 6));

    // 3-) Which AF mode
    GPIOA_AFRL &= ~((0xF << 8) | (0xF << 12));
    GPIOA_AFRL |= ((7 << 8) | (7 << 12));

    // 4-) Baudrate : Pclk = 4 Mhz, target 115200 baud
    USART2_BRR = 35; // 4000000 / 115200 = 35

    // 5-) Enable transmitter
    USART2_CR1 |= (1 << 3); // TE: Transmitter Enable
    USART2_CR1 |= (1 << 0); // UE: Usart Enable

}   

void uart_putc(char c)
{
    while(!(USART2_ISR & (1 << 7)))
        ;

    USART2_TDR = (unsigned int) c;
}

void uart_puts(const char *c)
{
    while(!(*c == '\0'))
    {
        uart_putc(*c);
        c++;
    }
}

void uart_put_num(unsigned int n)
{
    char buf[11];
    int i =0;

    if(n==0){ uart_putc('0'); return;}
    while (n > 0){ buf[i++] = '0' + (n%10); n/=10;}
    while (i > 0) uart_putc(buf[--i]);
}