cmake_minimum_required(VERSION 3.20)

message(STATUS "Running : arm-none-eabi.cmake")

###################### CONSTANTS ######################################
set(PROJECT_TYPE_EXECUTABLE          "exe")
set(PROJECT_TYPE_STATIC_LIBRARY      "static-lib")
set(MCPU_CORTEX_M0                   "-mcpu=cortex-m0")
set(MCPU_CORTEX_M0PLUS               "-mcpu=cortex-m0plus")
set(MCPU_CORTEX_M3                   "-mcpu=cortex-m3")
set(MCPU_CORTEX_M4                   "-mcpu=cortex-m4")
set(MCPU_CORTEX_M7                   "-mcpu=cortex-m7")
set(MCPU_CORTEX_M33                  "-mcpu=cortex-m33")
set(MCPU_CORTEX_M55                  "-mcpu=cortex-m55")
set(MCPU_CORTEX_M85                  "-mcpu=cortex-m85")
set(MFPU_FPV4_SP_D16                 "-mfpu=fpv4-sp-d16")
set(MFPU_FPV5_D16                    "-mfpu=fpv5-d16")
set(RUNTIME_LIBRARY_REDUCED_C        "--specs=nano.specs")
set(RUNTIME_LIBRARY_STD_C            "")
set(RUNTIME_LIBRARY_SYSCALLS_MINIMAL "--specs=nosys.specs")
set(RUNTIME_LIBRARY_SYSCALLS_NONE    "")
set(MFLOAT_ABI_SOFTWARE              "-mfloat-abi=soft")
set(MFLOAT_ABI_HARDWARE              "-mfloat-abi=hard")
set(MFLOAT_ABI_MIX                   "-mfloat-abi=softfp")
#######################################################################

set(CMAKE_SYSTEM_PROCESSOR  arm)
set(CMAKE_SYSTEM_NAME       Generic)

set(CMAKE_C_COMPILER_WORKS   TRUE)
set(CMAKE_CXX_COMPILER_WORKS TRUE)

set(CMAKE_TRY_COMPILE_TARGTE_TYPE   STATIC_LIBRARY)

set(TARGET      STM32F103xB)
set(MCPU        ${MCPU_CORTEX_M3})
set(ARM_ISA     mthumb)
set(MFLOAT_ABI  -mfloat-abi=soft)

set(CMAKE_C_COMPILER    arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER  arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER  arm-none-eabi-gcc)
set(CMAKE_SIZE          arm-none-eabi-size)
set(CMAKE_OBJDUMP       arm-none-eabi-objdump)
set(CMAKE_OBJCOPY       arm-none-eabi-objcopy)

set(OPTIMISATION Og)
set(DEBUG "g3")

set(WARN_FLAGS          "-Wall -Wextra -Wpedantic -pedantic -Wmissing-include-dirs -Wconversion -Wfatal-errors")
set(CMAKE_COMMON_FLAGS  "${MCPU} ${MFLOAT_ABI} -${ARM_ISA} -D${TARGET} -DUSE_HAL_DRIVER -${OPTIMISATION} -${DEBUG} ${WARN_FLAGS} -Og -v -ffunction-sections -fdata-sections -fstack-usage -fcyclomatic-complexity --specs=nano.specs")
set(CMAKE_ASM_FLAGS     "${MCPU} ${MFLOAT_ABI} -x assembler-with-cpp --specs=nano.specs -mthumb")
set(CMAKE_C_FLAGS       "${CMAKE_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS     "${CMAKE_COMMON_FLAGS} -std=gnu++17 -fno-rtti -fno-use-cxa-atexit -fno-exceptions -Wno-volatile")
set(CMAKE_LINKER_FLAGS  "--specs=nosys.specs -Wl,-Map=\"${TARGET}.map\" -Wl,--gc-sections -static ${MFLOAT_ABI} -mthumb -Wl,--start-group -lc -lm -lstdc++ -lsupc++ -Wl,--end-group")