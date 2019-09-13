CPUID_CACHE_PARAM_LEAF          equ 0x04
CPUID_TOPOLOGY_LEAF             equ 0x0B
CPUID_TOPOLOGY_CORE_LEVEL_TYPE  equ 0x02
CPUID_TOPOLOGY_INVALID_TYPE     equ 0x00

section .text

global xsti_cache_size
global xsti_logical_cores
global xsti_base_frequency
global xsti_max_frequency

;1st arg -- cache level
xsti_cache_size:

;save rbx to restore on return
push rbx

;set the cache parameters laef for cpuid
mov eax, CPUID_CACHE_PARAM_LEAF

;set the cache index argument for cpuid
;passed as the first function argument
mov rcx, rdi

;the cpuid instruction for the leaf will 
cpuid

;account number of sets
mov eax, ecx
inc eax

;account line size
mov r11d, ebx
and r11d, 0xfff ;zero bits not used for line size
inc r11d
mul r11d

;account line partitions
mov r11d, ebx
shr r11d, 12    ;shift out the line size bits accounted before
and r11d, 0x3ff ;zero bits not used for partitions count
inc r11d
mul r11d

;account associativity ways
mov r11d, ebx
shr r11d, 22    ;shift out the partitions count bits accounted before
and r11d, 0x3ff ;zero bits not used for partitions count
inc r11d
mul r11d

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
pop rbx
ret