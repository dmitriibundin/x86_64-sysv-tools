################################################################
#      To create a symlink chain during installation see       #
#  https://cmake.org/cmake/help/latest/command/file.html#copy  #
################################################################
cmake_minimum_required(VERSION 3.10)

project(x86tools C ASM_NASM) 

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake)

#Generate sources:
# - convert c headers to nasm headers
set(X86T_AUTOGENERATED_SRC_DIR_ASM_NASM_INC ${CMAKE_CURRENT_BINARY_DIR}/autogenerated_src/asm/include)
set(X86T_C_HEADERS_CONVERT_NASM ${CMAKE_CURRENT_SOURCE_DIR}/include/errors.h)
include(generate_source)

#Compile and assemble
set(X86T_C_FLAGS "-Wno-unused-variable \
                    -Wextra \
                    -Werror \
                    -pedantic \
                    -Wstrict-prototypes\
                    -Wconversion \
                    -Wattributes \
                    -fno-stack-protector \
                    -g3 \
                    -O3")
set(X86T_C_SOURCES main.c)

set(X86T_ASM_NASM_FLAGS "-f elf64 -g")
#This is to workaround necessary trailing slash in the include path.
#See https://bugzilla.nasm.us/show_bug.cgi?id=3392205
set(X86T_ASM_NASM_FLAGS "${X86T_ASM_NASM_FLAGS} -I${X86T_AUTOGENERATED_SRC_DIR_ASM_NASM_INC}/")

set(X86T_ASM_NASM_BINARY_SOURCES main.S)
set(X86T_ASM_NASM_SOURCES min.S src/info.S)
include(compile_assemble)