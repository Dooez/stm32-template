#include <stm32f4xx_hal.h>

int main()
{
    HAL_Init();
    // 1kHz ticks
    HAL_SYSTICK_Config(SystemCoreClock / 1000);
    int a = 0;
    while (1)
    {
        a = (a + 1) % 4;
    }
    return 0;
}
