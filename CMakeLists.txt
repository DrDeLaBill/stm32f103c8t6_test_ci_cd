cmake_minimum_required(VERSION 3.10)


###################### MACROS #########################################
MACRO(FILE_DIRECTORIES target_path return_list extention)
    FILE(GLOB_RECURSE new_list "${target_path}/*.${extention}")
    SET(dir_list "")
    FOREACH(file_path ${new_list})
        GET_FILENAME_COMPONENT(dir_path ${file_path} PATH)
        SET(dir_list "${dir_list};${dir_path}")
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES dir_list)
    SET(${return_list} ${dir_list})
ENDMACRO()

MACRO(FILE_PATHS target_path return_list extention)
    FILE(GLOB_RECURSE files_list "${target_path}/*.${extention}")
    LIST(REMOVE_DUPLICATES files_list)
    SET(${return_list} ${files_list})
ENDMACRO()
#######################################################################


# Отключаем создание тестового проекта для компилятора
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Название проекта
project(STMCMAKE C CXX ASM)

# Указываем стандарт C++ и C
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Указываем целевую систему
set(CMAKE_SYSTEM_NAME       Generic)
set (CMAKE_SYSTEM_PROCESSOR "arm")
set (CMAKE_CROSSCOMPILING   "TRUE")

# Указываем путь к компилятору
# set(CMAKE_C_COMPILER arm-none-eabi-gcc)
# set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
# set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)

# Указываем путь к компоновщику
file(GLOB LINKER_SCRIPT_PATH "*.ld")
set(LINKER_SCRIPT ${LINKER_SCRIPT_PATH})
message(STATUS "LINKER: ${LINKER_SCRIPT}")

# Указываем флаги компиляции
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcpu=cortex-m3 --specs=nano.specs -mthumb -v -Wall -Wextra -Wpedantic -Wfatal-errors")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mcpu=cortex-m3 --specs=nano.specs -mthumb -v -Wall -Wextra -Wpedantic -Wfatal-errors")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -mcpu=cortex-m3 --specs=nano.specs -mthumb -v -Wall -Wextra -Wpedantic -Wfatal-errors")

# Указываем флаги компоновщика
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T ${LINKER_SCRIPT} --specs=nosys.specs -Wl,--gc-sections -static -Wl,--start-group -lc -lm -Wl,--end-group")

# Указываем исходные файлы проекта
FILE_PATHS("./Drivers" drivers_c_paths "c")
FILE_PATHS("./Utils/utils" utils_c_paths "c")
FILE_PATHS("./Utils/utils" utils_c_paths "cpp")
file(GLOB ${PROJECT_NAME}_CPP_SOURCES "./Core/Src/*.cpp")
file(GLOB ${PROJECT_NAME}_C_SOURCES "./Core/Src/*.c")
file(GLOB ${PROJECT_NAME}_S_SOURCES "./Core/Startup/*.s")
set(SOURCES "${drivers_c_paths};${utils_c_paths};${utils_c_paths};${${PROJECT_NAME}_CPP_SOURCES};${${PROJECT_NAME}_C_SOURCES};${${PROJECT_NAME}_S_SOURCES}")
message(STATUS "PROJECT SOURCES: ${SOURCES}")

# Добавляем исполняемый файл
add_executable(${PROJECT_NAME}.elf ${SOURCES})

# Указываем дополнительные библиотеки, если необходимо
add_subdirectory(Utils)
target_link_libraries(${PROJECT_NAME}.elf utilslib)

# Указываем директории с заголовочными файлами
FILE_DIRECTORIES("./Drivers" drivers_h_dirs "h")
set (INCLUDES  "./Core/Inc;${drivers_h_dirs};${utils_h_dirs}")
include_directories(${INCLUDES})
message(STATUS "PROJECT INCLUDES: ${INCLUDES}")

# Указываем текущую платформу и драйвер
set (PROJECT_DEFINES STM32F103xB USE_HAL_DRIVER)
add_compile_definitions(${PROJECT_DEFINES})

# Указываем путь к файлу компоновщика
set_target_properties(${PROJECT_NAME}.elf PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT})

# Добавляем команду для генерации hex файла
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMENT "Building ${PROJECT_NAME}.hex"
)
