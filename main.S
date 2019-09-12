EXIT_SUCCESS                            equ 0
SYS_exit                                equ 0x3C

CPUID_CACHE_PARAMETERS_ID               equ 0x04
CPUID_CACHE_PARAMETERS_MSK              equ 0x7ff

CPUID_TOPOLOGY_PARAMETER_ID             equ 0x0B
CPUID_TOPOLOGY_PARAMETER_CORE_LEVEL_ID  equ 0x02

CPUID_VENDOR_STRING_ID                  equ 0x17

section .text

global _start

_start:
    call extended_max_addr
    call extended_invariant_info
    call extended_cache_info
    call cpu_brand_string
    call extended_cpu_features
    call extended_cpuid_max
    mov rdi, data_1
    call generate_some_data

    mov rdi, data_2
    call generate_some_data

    vmovaps ymm0, [data_1]
    vmovaps ymm1, [data_2]

    vpmulld ymm0, ymm1

    call cpu_get_vendor_string

    mov rdi, 0x03
    call get_cache_line_size

    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall

extended_max_addr:
    push rbx

    mov eax, 0x80000008
    cpuid

    pop rbx
    ret

extended_invariant_info:
    push rbx

    mov eax, 0x80000007
    cpuid

    pop rbx
    ret

extended_cache_info:
    push rbx

    mov eax, 0x80000006
    cpuid

    pop rbx
    ret
cpu_brand_string:
    push rbx

    sub rsp, 0x100
    mov eax, 0x80000002
    cpuid

    mov [rsp], eax
    mov [rsp + 0x04], ebx
    mov [rsp + 0x08], ecx
    mov [rsp + 0x0C], edx

    add rsp, 0x100
    pop rbx
    ret
extended_cpu_features:
    push rbx

    mov eax, 0x80000001
    cpuid

    pop rbx
    ret

extended_cpuid_max:
    push rbx
    
    mov eax, 0x80000000
    cpuid

    pop rbx
    ret

generate_some_data:
    mov qword [rdi], 1
    mov qword [rdi + 8], 2
    mov qword [rdi + 0x10], 3
    mov qword [rdi + 0x18], 4
    
    ret

cpu_get_vendor_string:
    push rbx

    ;adjust stack pointer for the current stack frame
    sub rsp, 0x1000

    ;save a pointer on stack for the resulting vendor string
    mov r10, rsp
    
    ;used for traversing the SOC vendor brand string
    ;returned by cpuid
    mov r11, 1

cpu_get_vendor_string_loop:
    mov eax, CPUID_VENDOR_STRING_ID
    mov ecx, r11d
    cpuid

    mov [r10], eax
    mov [r10 + 0x04], ebx
    mov [r10 + 0x08], ecx
    mov [r10 + 0x0C], edx

    add r10, 0x0C
    inc r11

    ;check if we have some SOC vendor attribute sub-leaf 
    ;left unprocessed
    cmp r11, 3
    jbe cpu_get_vendor_string_loop

    mov rax, rsp
    add rsp, 0x1000
    pop rbx
    ret

cpu_topology_get_logical_count:
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

;1st argument - the cache level
get_cache_line_size:
    push rbx
    ;set line number argument to be used with CPUID instruction
    mov ecx, edi 
    ;set cpuid initial value
    mov eax, CPUID_CACHE_PARAMETERS_ID

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


section .bss
    align 32
    data_1: resq 4
    data_2: resq 4