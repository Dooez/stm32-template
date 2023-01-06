
function(fetch_svd MCU)
    message("-- Search for .svd files: ${MCU}")
    set_svd_contents()
    set(FETCH_FILES "")
    foreach(SVD_FILE ${SVD_CONTENTS})
        string(FIND ${SVD_FILE} "_" UNDERSCORE_POS)
        if(UNDERSCORE_POS EQUAL -1)
            string(LENGTH  ${SVD_FILE} SVD_NAME_LENGTH)
            math(EXPR SVD_NAME_LENGTH "${SVD_NAME_LENGTH}-4")
            string(SUBSTRING ${SVD_FILE} 0 ${SVD_NAME_LENGTH} SVD_NAME)
        else()
            string(SUBSTRING ${SVD_FILE} 0 ${UNDERSCORE_POS} SVD_NAME)
        endif()
        string(REPLACE "x" "[A-Z0-9]" SVD_REGEX ${SVD_NAME})
        string(APPEND SVD_REGEX "[A-Z0-9]*")
        string(REGEX MATCH ${SVD_REGEX} FOUND ${MCU})

        if(NOT ${FOUND} STREQUAL  "")
            list(APPEND FETCH_FILES ${SVD_FILE})
        endif()
    endforeach()
    list(LENGTH FETCH_FILES NUMBER_FILES)
    if(${NUMBER_FILES} GREATER 0)
        foreach(SVD_FILE ${FETCH_FILES})
            if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/SVD/${SVD_FILE})
                file(DOWNLOAD https://raw.githubusercontent.com/posborne/cmsis-svd/master/data/STMicro/${SVD_FILE} ${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/SVD/${SVD_FILE})
            endif()
            if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/SVD/${SVD_FILE})
                message(WARNING "Could not download ${SVD_FILE} from remote repository")
            endif()
        endforeach()

        message("-- Search for .svd files: ${MCU} done")
    else()
        message(WARNING "Could not find fitting .svd files for ${MCU}")
    endif()
endfunction()

function(set_svd_contents)
    set(SVD_CONTENTS
    STM32F030.svd
    STM32F031x.svd
    STM32F042x.svd
    STM32F072x.svd
    STM32F091x.svd
    STM32F0xx.svd
    STM32F100xx.svd
    STM32F101xx.svd
    STM32F102xx.svd
    STM32F103xx.svd
    STM32F105xx.svd
    STM32F107xx.svd
    STM32F20x.svd
    STM32F21x.svd
    STM32F301.svd
    STM32F302.svd
    STM32F303.svd
    STM32F373.svd
    STM32F3x4.svd
    STM32F3x8.svd
    STM32F401.svd
    STM32F405.svd
    STM32F407.svd
    STM32F410.svd
    STM32F411.svd
    STM32F412.svd
    STM32F413.svd
    STM32F427.svd
    STM32F429.svd
    STM32F446.svd
    STM32F469.svd
    STM32F730.svd
    STM32F745.svd
    STM32F750.svd
    STM32F765.svd
    STM32F7x2.svd
    STM32F7x3.svd
    STM32F7x5.svd
    STM32F7x6.svd
    STM32F7x7.svd
    STM32F7x8.svd
    STM32F7x9.svd
    STM32F7x.svd
    STM32G030.svd
    STM32G031.svd
    STM32G041.svd
    STM32G050.svd
    STM32G051.svd
    STM32G061.svd
    STM32G070.svd
    STM32G071.svd
    STM32G07x.svd
    STM32G081.svd
    STM32G0B0.svd
    STM32G0B1.svd
    STM32G0C1.svd
    STM32G431xx.svd
    STM32G441xx.svd
    STM32G471xx.svd
    STM32G473xx.svd
    STM32G474xx.svd
    STM32G483xx.svd
    STM32G484xx.svd
    STM32G491xx.svd
    STM32G4A1xx.svd
    STM32GBK1CBT6.svd
    STM32H742x.svd
    STM32H743x.svd
    STM32H750x.svd
    STM32H753x.svd
    STM32H7A3x.svd
    STM32H7B3x.svd
    STM32H7x3.svd
    STM32H7x5_CM4.svd
    STM32H7x5_CM7.svd
    STM32H7x7_CM4.svd
    STM32H7x7_CM7.svd
    STM32L0x1.svd
    STM32L0x2.svd
    STM32L0x3.svd
    STM32L100.svd
    STM32L15xC.svd
    STM32L15xxE.svd
    STM32L15xxxA.svd
    STM32L1xx.svd
    STM32L4R5.svd
    STM32L4R7.svd
    STM32L4R9.svd
    STM32L4S5.svd
    STM32L4S7.svd
    STM32L4S9.svd
    STM32L4x1.svd
    STM32L4x2.svd
    STM32L4x3.svd
    STM32L4x5.svd
    STM32L4x6.svd
    STM32L552.svd
    STM32L562.svd
    STM32W108.svd
    PARENT_SCOPE)
endfunction()