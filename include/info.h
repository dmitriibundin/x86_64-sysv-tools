#ifndef X86_SYSV_TOOLS_INFO_H
#define X86_SYSV_TOOLS_INFO_H

#ifdef __cplusplus
extern "C" {
#endif

//Namespace xsti -- x86_sysv_tools_info

unsigned xsti_cache_size(unsigned cache_level);

unsigned xsti_logical_cores(void);

unsigned xsti_base_frequency(void);

unsigned xsti_max_frequency(void);

int xsti_cpu_brand_string(char *buf, size_t len);

#ifdef __cplusplus
}
#endif
#endif //X86_SYSV_TOOLS_INFO_H