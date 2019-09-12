cmake_minimum_required(VERSION 3.10)

project(stdx86 C ASM_NASM)

set(STDX_ASM_NASM_BINARY_SOURCES main.S)

set(CMAKE_ASM_NASM_LINK_EXECUTABLE "ld <FLAGS> <CMAKE_ASM_NASM_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")

set(STDX_ASM_NASM_SOURCES min.S src/info.S)
set(STDX_ASM_NASM_FLAGS "-f elf64 -g")

set(STDX_C_SOURCES main.c)
set(STDX_C_FLAGS "-Wno-unused-variable -Wextra -Werror -pedantic -Wstrict-prototypes -Wconversion -Wattributes -fno-stack-protector -g3 -O3")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${STDX_C_FLAGS}")

set_source_files_properties(${STDX_ASM_NASM_SOURCES} ${STDX_ASM_NASM_BINARY_SOURCES} PROPERTIES LANGUAGE ASM_NASM)
set(CMAKE_ASM_NASM_COMPILE_OBJECT "${CMAKE_ASM_NASM_COMPILE_OBJECT} ${STDX_ASM_NASM_FLAGS}")

include_directories(include)
add_executable(bin ${STDX_C_SOURCES} ${STDX_ASM_NASM_SOURCES})
set_target_properties(bin PROPERTIES LINKER_LANGUAGE C)

add_executable(bin_asm ${STDX_ASM_NASM_BINARY_SOURCES})
set_target_properties(bin_asm PROPERTIES LINKER_LANGUAGE ASM_NASM)