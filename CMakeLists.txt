cmake_minimum_required(VERSION 3.16)
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/stm32-cmake/cmake/stm32_gcc.cmake)
include(fetch_svd.cmake)

# Select MCU model:
set(MCU STM32F401CC)

# Set project name to match directory name. If set othervise tasks.json and launch.json should be updated
get_filename_component(BASE_FOLDER ${CMAKE_CURRENT_SOURCE_DIR} NAME)
set(PROJECT_NAME ${BASE_FOLDER})

project(${PROJECT_NAME} C CXX ASM)


# MCU familiy from MCU
string(SUBSTRING ${MCU} 5 2 MCU_FAMILY)
string(SUBSTRING ${MCU} 5 6 MCU_MODEL)

# Fetch HAL, CMSIS, and CMSIS-SVD
fetch_svd(${MCU})
stm32_fetch_cmsis(${MCU_FAMILY})
stm32_fetch_hal(${MCU_FAMILY})

find_package(CMSIS COMPONENTS  ${MCU} REQUIRED)
find_package(HAL COMPONENTS STM32${MCU_FAMILY} REQUIRED)


add_executable(${PROJECT_NAME} main.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Link required libraries
target_link_libraries(${PROJECT_NAME}
    HAL::STM32::${MCU_FAMILY}::RCC
    HAL::STM32::${MCU_FAMILY}::GPIO
    HAL::STM32::${MCU_FAMILY}::CORTEX
    CMSIS::STM32::${MCU_MODEL}
    STM32::Nano # use newlib nano to reduce code size.
    STM32::NoSys
)

stm32_print_size_of_target(${PROJECT_NAME})
stm32_generate_binary_file(${PROJECT_NAME})
stm32_generate_hex_file(${PROJECT_NAME})