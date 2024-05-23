cmake_minimum_required(VERSION 3.20)


include("arm-none-eabi-gcc.cmake")


message(STATUS "C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER}")


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


# Название проекта
project(STMCMAKE VERSION 0.1.0)
message(STATUS "Building ${PROJECT_NAME}")
message(STATUS "C FLAGS:   ${CMAKE_C_FLAGS}")
message(STATUS "C++ FLAGS: ${CMAKE_CXX_FLAGS}")
message(STATUS "ASM FLAGS: ${CMAKE_ASM_FLAGS}")

# Включаем Assembler
enable_language(ASM)

# Указываем стандарт C++ и C
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Указываем исходные файлы проекта
FILE_PATHS("./Drivers" drivers_c_paths "c")
FILE_PATHS("./Modules/Utils/utils" utils_c_paths "c")
FILE_PATHS("./Modules/Utils/utils" utils_cpp_paths "cpp")
file(GLOB ${PROJECT_NAME}_CPP_SOURCES "./Core/Src/*.cpp")
file(GLOB ${PROJECT_NAME}_C_SOURCES "./Core/Src/*.c")
file(GLOB ${PROJECT_NAME}_S_SOURCES "./Core/Startup/*.s")
set(SOURCES "${drivers_c_paths};${utils_c_paths};${utils_cpp_paths};${${PROJECT_NAME}_CPP_SOURCES};${${PROJECT_NAME}_C_SOURCES};${${PROJECT_NAME}_S_SOURCES}")

# Добавляем исполняемый файл
add_executable(${PROJECT_NAME}.elf ${SOURCES})

# Указываем путь к файлу компоновщика
file(GLOB LINKER_SCRIPT_PATH "./*.ld")
set(LINKER_SCRIPT ${LINKER_SCRIPT_PATH})
set_target_properties(${PROJECT_NAME}.elf PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT})

# Указываем флаги компоновщика
set(TMP_LINKER_FLAGS ${CMAKE_LINKER_FLAGS})
set(CMAKE_EXE_LINKER_FLAGS "-T\"${LINKER_SCRIPT}\" ${TMP_LINKER_FLAGS}")
set(CMAKE_LINKER_FLAGS "-T\"${LINKER_SCRIPT}\" ${TMP_LINKER_FLAGS}")
message(STATUS "Linker: ${CMAKE_LINKER_FLAGS}")

# Указываем директории с заголовочными файлами
FILE_DIRECTORIES("./Drivers" drivers_h_dirs "h")
FILE_DIRECTORIES("./Modules/Utils" utils_h_dirs "h")
set (INCLUDES  "./Core/Inc;${drivers_h_dirs};${utils_h_dirs}")
include_directories(${INCLUDES})
message(STATUS "PROJECT INCLUDES: ${INCLUDES}")
message(STATUS "PROJECT SOURCES: ${SOURCES}")

# Указываем дополнительные библиотеки, если необходимо
# add_subdirectory("./Modules/Utils")
# target_link_libraries(${PROJECT_NAME}.elf utilslib)

# Добавляем команду для генерации hex файла
add_custom_command(
    TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMENT "Building ${PROJECT_NAME}.hex"
)

# Добавляем команду для генерации bin файла
add_custom_command(
    TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary ./${PROJECT_NAME}.elf ./${PROJECT_NAME}.bin
    COMMENT "Building ${PROJECT_NAME}.bin"
)