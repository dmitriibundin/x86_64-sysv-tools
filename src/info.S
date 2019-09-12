CPUID_CACHE_PARAM_LEAF equ 0x04

section .text

global xsti_cache_size
global xsti_logical_cores
global xsti_base_frequency
global xsti_max_frequency

;1st arg -- cache level
xsti_cache_size:

;save rbx to restore later
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
mov r10d, ebx
and r10d, 0xfff ;zero bits not used for line size
inc r10d
mul r10d

;account line partitions
mov r10d, ebx
shr r10d, 12    ;shift out the line size bits accounted before
and r10d, 0x3ff ;zero bits not used for partitions count
inc r10d
mul r10d

;account associativity ways
mov r10d, ebx
shr r10d, 22    ;shift out the partitions count bits accounted before
and r10d, 0x3ff ;zero bits not used for partitions count
inc r10d
mul r10d

;restore rbx
pop rbx
ret