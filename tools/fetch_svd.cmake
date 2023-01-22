function(fetch_svd MCU)
    set(ENV{BEST_FIT_SVD} "")
    message("-- Search for .svd files: ${MCU}")

    # Trying to fetch from st.com
    string(SUBSTRING ${MCU} 5 2 MCU_FAMILY)
    string(TOLOWER ${MCU_FAMILY}  MCU_FAMILY_L)
    file(DOWNLOAD https://www.st.com/resource/en/svd/stm32${MCU_FAMILY_L}_svd.zip STATUS ST_DL_STATUS)
    list(GET ST_DL_STATUS 1 ST_DL_ERROR)

    if (${ST_DL_ERROR} STREQUAL "\"No error\"")
        if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.24.0")
            set(FETCH_CONTENT_PARAMETERS DOWNLOAD_EXTRACT_TIMESTAMP TRUE)
        endif()
        FetchContent_Declare(
            st-svd-archive
            URL      https://www.st.com/resource/en/svd/stm32${MCU_FAMILY_L}_svd.zip
            ${FETCH_CONTENT_PARAMETERS}
        )
        FetchContent_MakeAvailable(st-svd-archive)
        file(GLOB_RECURSE SVD_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/st-svd-archive-src/*.svd)
        set(MATCH_WEIGHT_MAX 0)
        foreach(SVD_FILE_PATH ${SVD_FILES})
            get_filename_component(SVD_FILE ${SVD_FILE_PATH} NAME)
            match_mcu_to_file(${MCU} ${SVD_FILE} ".svd" MATCH_WEIGHT)
            if (${MATCH_WEIGHT} GREATER ${MATCH_WEIGHT_MAX})
                set(MATCH_WEIGHT_MAX ${MATCH_WEIGHT})
                set(ENV{BEST_FIT_SVD} ${SVD_FILE_PATH})
            endif()
        endforeach()
    endif()

    if (NOT $ENV{BEST_FIT_SVD} STREQUAL "")
        get_filename_component(SVD_NAME_ONLY $ENV{BEST_FIT_SVD} NAME)
        file(MAKE_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/SVD/)
        file(COPY_FILE "${CMAKE_CURRENT_SOURCE_DIR}/$ENV{BEST_FIT_SVD}" "${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/SVD/${SVD_NAME_ONLY}" RESULT SVD_COPY_ERROR ONLY_IF_DIFFERENT)
        if(NOT SVD_COPY_ERROR EQUAL 0)
            message("Error copying .svd file, using initial path. Error: ${SVD_COPY_ERROR}")
        else()
            set(ENV{BEST_FIT_SVD} build/_deps/SVD/${SVD_NAME_ONLY})
        endif()
        message("-- Search for .svd files: ${MCU} done. Relative path: $ENV{BEST_FIT_SVD}")
        return()
    endif()

    # Could not fetch from st.com, trying to find https://github.com/posborne/cmsis-svd
    message("-- Search for .svd files: Could not fetch .svd file from st.com, trying https://github.com/posborne/cmsis-svd")
    set_svd_repo_contents()
    set(SVD_FILE "")
    set(MATCH_WEIGHT_MAX 0)
    foreach(SVD_REPO_FILE ${SVD_REPO_CONTENTS})
    match_mcu_to_file(${MCU} ${SVD_REPO_FILE} ".svd" MATCH_WEIGHT)
        if (${MATCH_WEIGHT} GREATER ${MATCH_WEIGHT_MAX})
            set(MATCH_WEIGHT_MAX ${MATCH_WEIGHT})
            set(SVD_FILE ${SVD_REPO_FILE})
        endif()
    endforeach()

    if(${MATCH_WEIGHT_MAX} GREATER 0)
        if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/SVD/${SVD_FILE})
            file(DOWNLOAD https://raw.githubusercontent.com/posborne/cmsis-svd/master/data/STMicro/${SVD_FILE} ${CMAKE_CURRENT_SOURCE_DIR}/build/_deps/SVD/${SVD_FILE} STATUS REPO_DL_STATUS)
            list(GET REPO_DL_STATUS 1 REPO_DL_ERROR)
            if (NOT ${REPO_DL_ERROR} STREQUAL "\"No error\"")
                message(WARNING "-- Search for .svd files: Error downloading ${SVD_FILE} from remote repository: ${REPO_DL_ERROR}")
            endif()
        endif()
        set(ENV{BEST_FIT_SVD} /build/_deps/SVD/${SVD_FILE})
        message("-- Search for .svd files: ${MCU} done. Relative path: $ENV{BEST_FIT_SVD}")
    else()
        message(WARNING "-- Search for .svd files: Could not find fitting .svd files from remote repository for ${MCU}")
    endif()
endfunction()

# Generates or update launch.json
# CAREFUL: DELETES COMMENTS and rarranges all fields alphabetically
function(update_launch_json MCU)

    if(NOT EXISTS  ${CMAKE_CURRENT_SOURCE_DIR}/.vscode/launch.json)
        file(WRITE  ${CMAKE_CURRENT_SOURCE_DIR}/.vscode/launch.json "{\n    \"configurations\": [\n        {\n            \"name\": \"Cortex Debug ST-Util\",\n            \"type\": \"cortex-debug\",\n            \"request\": \"launch\",\n            \"servertype\": \"stutil\",\n            \"cwd\": \"\${workspaceRoot}\",\n            \"executable\": \"\${command:cmake.launchTargetPath}\",\n            \"preLaunchTask\": \"CMake: build\",\n            \"preRestartCommands\": [\n                \"load\",\n                \"enable breakpoint\",\n                \"monitor reset\"\n            ],\n            \"runToEntryPoint\": \"main\",\n            \"showDevDebugOutput\": \"raw\",\n            \"device\": \"\", /* #update this field with CMake */\n            \"svdFile\": \"\", /* #update this field with CMake */\n        }\n    ]\n}\n")
    endif()
    file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/.vscode/launch.json LAUNCH_JSON)

    if ("$ENV{BEST_FIT_SVD}" STREQUAL "")
        message(WARNING "No fitting .svd file defined. Try \"fetch_svd(${MCU})\"")
    endif()

    set(UPDATED_LAUNCH_JSON)
    foreach(STR ${LAUNCH_JSON})
        string(REGEX MATCH "^\\s*\"device\"\\s*:\\s*\".*\"\,?\\s\/\* #update this field with CMake \*\/" MATCHED STR)
        if(NOT ${MATCHED} STREQUAL "" )
            string(REGEX REPLACE "^\\s*\"device\"\\s*:\\s*\"(.*)\"\,?\\s\/\* #update this field with CMake \*\/" ${MCU} REPLACED STR)
                    endif()
        string(REGEX MATCH "^\\s*\"svdFile\"\\s*:\\s*\".*\"\,?\\s\/\* #update this field with CMake \*\/" MATCHED STR)
        if(NOT ${MATCHED} STREQUAL "" )
            string(REGEX REPLACE "^\\s*\"svdFile\"\\s*:\\s*\"(.*)\"\,?\\s\/\* #update this field with CMake \*\/" $ENV{BEST_FIT_SVD} REPLACED STR)
        endif()
        if(${REPLACED})
            list(APPEND UPDATED_LAUNCH_JSON ${REPLACED})
        else()
            list(APPEND UPDATED_LAUNCH_JSON ${STR})
        endif()
    endforeach()

    # file(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/.vscode/launch.json "")
#
    # foreach(STR ${UPDATED_LAUNCH_JSON})
        # file(APPEND ${CMAKE_CURRENT_SOURCE_DIR}/.vscode/launch.json ${STR}\n)
    # endforeach()
endfunction()

# Tries to match MCU with FILEEXTENSION and writes to <output>.
# If FILE fits MCU, <output> is the number of defined symbols in mcu name, otherwise <output> equals -1.
# Higher values of <output> should mean better match.

function(match_mcu_to_file MCU FILE EXTENSION output)
    string(FIND ${FILE} "_" UNDERSCORE_POS)
    if(UNDERSCORE_POS EQUAL -1)
        string(LENGTH ${FILE} FILE_NAME_LENGTH)
        string(LENGTH ${EXTENSION} EXTENSION_LENGTH)
        math(EXPR FILE_NAME_LENGTH "${FILE_NAME_LENGTH}-${EXTENSION_LENGTH}")
        string(SUBSTRING ${FILE} 0 ${FILE_NAME_LENGTH} FILE_NAME)
    else()
        string(SUBSTRING ${FILE} 0 ${UNDERSCORE_POS} FILE_NAME)
    endif()
    string(REGEX REPLACE "x" "" FILE_NAME_PREDEFINED ${FILE_NAME})
    string(LENGTH ${FILE_NAME_PREDEFINED} WEIGHT)

    string(REPLACE "x" "[A-Z0-9]" REGEX ${FILE_NAME})
    string(APPEND REGEX "[A-Z0-9]*")
    string(REGEX MATCH ${REGEX} FOUND ${MCU})

    if(NOT ${FOUND} STREQUAL  "")
        set(${output} ${WEIGHT} PARENT_SCOPE)
    else()
        set(${output} -1 PARENT_SCOPE)
    endif()
endfunction()


function(set_svd_repo_contents)
    set(SVD_REPO_CONTENTS
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

function(set_openocd_targets)
set(OPENOCD_TARGETS
    target/stm32f0x.cfg
    target/stm32f1x.cfg
    target/stm32f2x.cfg
    target/stm32f3x.cfg
    target/stm32f4x.cfg
    target/stm32f7x.cfg
    target/stm32g0x.cfg
    target/stm32g4x.cfg
    target/stm32h7x.cfg
    target/stm32h7x_dual_bank.cfg
    target/stm32l0.cfg
    target/stm32l0_dual_bank.cfg
    target/stm32l1.cfg
    target/stm32l1x_dual_bank.cfg
    target/stm32l4x.cfg
    target/stm32l5x.cfg
    target/stm32mp15x.cfg
    target/stm32w108xx.cfg
    target/stm32wbx.cfg
    target/stm32wlx.cfg
    target/stm32xl.cfg
    PARENT_SCOPE)
endfunction()