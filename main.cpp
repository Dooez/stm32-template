
#include <stm32f4xx_hal.h>
extern "C"
{
    void SysTick_Handler(void)
    {
        HAL_IncTick();
    }
}

void initGPIO()
{
    __HAL_RCC_GPIOC_CLK_ENABLE();

    GPIO_InitTypeDef GPIO_Config;

    GPIO_Config.Mode  = GPIO_MODE_OUTPUT_PP;
    GPIO_Config.Pull  = GPIO_NOPULL;
    GPIO_Config.Speed = GPIO_SPEED_FREQ_LOW;

    GPIO_Config.Pin = GPIO_PIN_13;

    HAL_GPIO_Init(GPIOC, &GPIO_Config);
}

int main(void)
{
    HAL_Init();
    initGPIO();

    constexpr uint32_t delay = 250;
    while (1)
    {
        HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);
        HAL_Delay(delay);
        HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);
        HAL_Delay(delay);
    }
    return 0;
}