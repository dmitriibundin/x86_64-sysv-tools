;syscall numbers
SYS_exit equ 0x3C

;exit codes
EXIT_SUCCESS equ 0

;cpuid cpu topology parameter values
CPUID_TOPOLOGY_PARAMETER_ID             equ 0x0B
CPUID_TOPOLOGY_PARAMETER_CORE_LEVEL_ID  equ 0x02

section .text

; global _start
global avx2_find_min

global get_cache_line_size

global cpu_topology_get_logical_cores

;1st arg - __m256 packed signed qwords
avx2_find_min:
    vmovaps ymm0, [rdi]
    lea rax, [rdi]
avx2_find_min_loop:
    vpbroadcastq ymm1, [rax]
    vpcmpgtq ymm1, ymm0
    vmovmskpd rdx, ymm1
    bsf rdx, rdx
    jz avx2_find_min_end_loop
    lea rax, [rdi + 8 * rdx]
    jmp avx2_find_min_loop
avx2_find_min_end_loop:
    ret

;1st argument - the cache level
get_cache_line_size:
    push rbx
    ;set line number argument to be used with CPUID instruction
    mov ecx, edi 
    ;set cpuid initial value
    mov eax, 0x04

    cpuid

    ;cache line size
    mov eax, ebx
    and eax, 0x7ff
    inc eax

    ;partitions
    shr ebx, 12
    mov edx, ebx
    and edx, 0x1ff
    inc edx
    mul edx

    ;ways of associativity
    shr ebx, 10
    mov edx, ebx
    and edx, 0x1ff
    inc edx
    mul edx

    ;number of sets
    inc ecx
    mul ecx

    pop rbx

    ret

cpu_topology_get_logical_cores:
    push rbx

    ;temporary register used for traversing cpu topology levels
    mov r10d, 0

    ;zero temporary register to accumulate logical cpu count
    xor r11, r11
cpu_topology_get_logical_count_loop:
    ;set cpuid parameter to get cpu topology
    mov eax, CPUID_TOPOLOGY_PARAMETER_ID

    ;initial topology level to start with
    mov ecx, r10d
    cpuid

    ;get current level type
    shr ecx, 8
    and ecx, 0xff

    ;if current level is invalid then all levels
    ;with higher level numbers are also invalid.
    jz cpu_topology_get_logical_count_loop_end

    ;we only need to count cores, so skip everything that is unrelated
    cmp ecx, CPUID_TOPOLOGY_PARAMETER_CORE_LEVEL_ID
    jne cpu_topology_get_logical_count_loop_continue

    and ebx, 0xffff
    add r11d, ebx

cpu_topology_get_logical_count_loop_continue:
    inc r10d
    jmp cpu_topology_get_logical_count_loop

cpu_topology_get_logical_count_loop_end:
    pop rbx
    mov rax, r11
    ret

section .bss
    align 32
    data: resq 4
    data_next_qword: resq 1