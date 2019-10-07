%include "errors.inc"

CPUID_INTEL_CACHE_LEAF_LEGACY           equ 0x02
CPUID_VENDOR_STRING_LEAF                equ 0x00
CPUID_VENDOR_UNKNOWN                    equ -1
CPUID_VENDOR_INTEL                      equ 0x00
CPUID_CACHE_PARAM_LEAF                  equ 0x04
CPUID_TOPOLOGY_LEAF                     equ 0x0B
CPUID_TOPOLOGY_CORE_LEVEL_TYPE          equ 0x02
CPUID_TOPOLOGY_INVALID_TYPE             equ 0x00
CPUID_FREQUENCY_LEAF                    equ 0x16
CPUID_BRAND_STRING_LEAF_1               equ 0x80000002
CPUID_BRAND_STRING_LEAF_2               equ 0x80000003
CPUID_BRAND_STRING_LEAF_3               equ 0x80000004
CPUID_BRAND_STRING_LEAF_BUFFER_SIZE     equ 4 * 4 * 3   ;4 4-bytes length register per each leaf
                                                        ;3 leafs in total
CPUID_CACHE_EXTENDED_LEAF               equ 0x80000006

section .rodata
    CPUID_VENDOR_STRING_INTEL:   db 'GenuineIntel', 0
;    align 64
;    CPUID_VENDOR_STRING_AMD     db "AuthenticAMD", 0

section .text

global xsti_cpu_vendor
global xsti_cache_size
global xsti_cache_line_size
global xsti_logical_cores
global xsti_frequencies
global xsti_cpu_brand_string
global xsti_get_tlb

;1st arg - vendor
xsti_get_tlb:

    ;save rbx to restore on return
    push rbx

    ; cmp 

    ;set intel cache leaf legacy for cpuid
    mov eax, CPUID_INTEL_CACHE_LEAF_LEGACY


xsti_get_tlb_return:
    pop rbx
    ret


xsti_cpu_vendor:
    ;save rbx to restore on return
    push rbx

    ;set vendor string leaf for cpuid
    mov eax, CPUID_VENDOR_STRING_LEAF

    cpuid

    mov r10, CPUID_VENDOR_STRING_INTEL
    ;compare the first 4 ASCII chars of the Intel vendor string
    cmp ebx, [r10]
    jne xsti_cpu_vendor_unknown

    ;compare the second 4 ASCII chars of the Intel vendor string
    cmp edx, [r10 + 0x04]
    jne xsti_cpu_vendor_unknown

    ;compare the third 4 ASCII chars of the Intek vendor string
    cmp ecx, [r10 + 0x08]
    jne xsti_cpu_vendor_unknown

    mov eax, CPUID_VENDOR_INTEL
    jmp xsti_cpu_vendor_return

    xsti_cpu_vendor_unknown:
        ;set unknown vendor return value
        mov eax, CPUID_VENDOR_UNKNOWN

    xsti_cpu_vendor_return:
    ;restore rbx and return
    pop rbx
    ret

;1st arg -- hidden struct xsti_cpu_cache pointer
;2nd arg -- cache level
xsti_cache_size:

    ;save rbx to restore on return
    push rbx

    ;set the cache parameters laef for cpuid
    mov eax, CPUID_CACHE_PARAM_LEAF

    ;set the cache index argument for cpuid
    ;passed as the first function argument
    mov rcx, rsi

    ;the cpuid instruction for the leaf will 
    cpuid

    ;account number of sets
    mov eax, ecx
    inc eax
    mov [rdi], eax ;set the number of sets to the first member of struct xsti_cpu_cache

    ;account line size
    mov r11d, ebx
    and r11d, 0xfff ;zero bits not used for line size
    inc r11d
    mov [rdi + 0x04], r11d  ;set the line size to the second member of struct xsti_cpu_cache
    mul r11d

    ;account line partitions
    mov r11d, ebx
    shr r11d, 12    ;shift out the line size bits accounted before
    and r11d, 0x3ff ;zero bits not used for partitions count
    inc r11d
    mov [rdi + 0x08], r11d;set the partitions to the third member of struct xsti_cpu_cache
    mul r11d

    ;account associativity ways
    mov r11d, ebx
    shr r11d, 22    ;shift out the partitions count bits accounted before
    and r11d, 0x3ff ;zero bits not used for partitions count
    inc r11d
    mov [rdi + 0x0c], r11d;set the associativity ways to the fourth member of struct xsti_cpu_cache
    mul r11d

    mov [rdi + 0x10], rax;set the total cache size at the current level to the fifth member of struct xsti_cpu_cache

    ;return the first hidden argument
    ;as require by SystemV ABI.
    mov rax, rdi
    ;restore rbx and return
    pop rbx
    ret

xsti_logical_cores:

    ;save rbx to restore on return
    push rbx

    ;zero return value accumlator
    xor r11d, r11d
    ;zero initial subleaf value to traverse cpu topology
    xor r10d, r10d

    xsti_logical_cores_loop:
    ;set cpu topology leaf value for cpuid
    mov eax, CPUID_TOPOLOGY_LEAF
    ;subleaf value used for traversing
    mov ecx, r10d

    cpuid

    shr ecx, 8      ;shift right by level type offset
    and ecx, 0xff   ;zero bits not used for level type
    cmp ecx, CPUID_TOPOLOGY_INVALID_TYPE
    ;invalid level encountered meaning that topology traversing is done.
    je xsti_logical_cores_loop_end
    ;advance to the next level
    inc r10d
    cmp ecx, CPUID_TOPOLOGY_CORE_LEVEL_TYPE
    jne xsti_logical_cores_loop
    ;core topology level encountered, accumulate number of cores at this level
    and ebx, 0xffff ;zero bits not used in number of logical cores
    add r11d, ebx
    jmp xsti_logical_cores_loop
    xsti_logical_cores_loop_end:

    mov eax, r11d
    ;restore rbx and return
    pop rbx
    ret

xsti_frequencies:

    ;save rbx to restore on return
    push rbx

    ;set frequency leaf for cpuid
    mov eax, CPUID_FREQUENCY_LEAF

    cpuid

    ;set base and max frequence to the first return register
    and eax, 0xffff ;zero bits not used for base frequency
    and ebx, 0xffff ;zero bits not used for max frequency
    shl rbx, 32
    or rax, rbx

    ;set bus frequency
    and ecx, 0xffff ;zero bits not used for max frequency
    mov edx, ecx

    ;restore rbx and return
    pop rbx
    ret

;1st argument - pointer to a buffer
;2nd argument - buffer size
xsti_cpu_brand_string:
    ;compare if the buffer size is enough to hold
    ;the max of possible value of CPU brand string
    cmp rsi, CPUID_BRAND_STRING_LEAF_BUFFER_SIZE
    jae xsti_cpu_brand_string_valid_buffer

    ;return the minimum required buffer size
    mov rax, CPUID_BRAND_STRING_LEAF_BUFFER_SIZE
    ret

    xsti_cpu_brand_string_valid_buffer:
    ;save rbx to restore on return
    push rbx

    ;zero buffer offset counter
    xor r10d, r10d

    ;set the first part brand string leaf to cpuid
    mov eax, CPUID_BRAND_STRING_LEAF_1

    cpuid

    ;copy the resulting brand string part of this leaf
    ;to the buffer pointed to by rdi
    mov [rdi]       , eax
    mov [rdi + 0x04], ebx
    mov [rdi + 0x08], ecx
    mov [rdi + 0x0c], edx
    add rdi, 0x10

    ;set the second part brand string leaf to cpuid
    mov eax, CPUID_BRAND_STRING_LEAF_2

    cpuid

    ;copy the resulting brand string part of this leaf
    ;to the buffer pointed to by rdi
    mov [rdi], eax
    mov [rdi + 0x04], ebx
    mov [rdi + 0x08], ecx
    mov [rdi + 0x0c], edx
    add rdi, 0x10

    ;set the third part brand string leaf to cpuid
    mov eax, CPUID_BRAND_STRING_LEAF_3

    cpuid

    ;copy the resulting brand string part of this lead
    ;to the buffer pointed to by rdi
    mov [rdi], eax
    mov [rdi + 0x04], ebx
    mov [rdi + 0x08], ecx
    mov [rdi + 0x0c], edx
    add rdi, 0x10

    mov rax, 0
    ;restore rbx and return
    pop rbx
    ret

xsti_cache_line_size:

    ;save rbx to restore on return
    push rbx

    ;set cache extended leaf to cpuid
    mov eax, CPUID_CACHE_EXTENDED_LEAF

    cpuid

    and ecx, 0xff   ;zero bits not used in cache line size
    mov eax, ecx

    ;restore rbx and return
    pop rbx
    ret