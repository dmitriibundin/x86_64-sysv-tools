#ifndef X86_SYSV_TOOLS_INFO_H
#define X86_SYSV_TOOLS_INFO_H

#ifdef __cplusplus
extern "C" {
#endif

//Namespace xsti -- x86_sysv_tools_info

unsigned xsti_cache_size(unsigned cache_level);

unsigned xsti_logical_cores(void);

struct xsti_frequencies{
    unsigned base_cpu_frequency;
    unsigned max_cpu_frequency;
    unsigned bus_frequency;
};

struct xsti_frequencies xsti_frequencies(void);

/**
 * Reads the brand string of this CPU into the buffer passed in as the first argument
 * with the size as the second argument.
 * 
 * Returns:
 *  minimum required buffer size - if the buffer is too small
 *  0                            - on success
 */
unsigned xsti_cpu_brand_string(char *buf, size_t len);

#ifdef __cplusplus
}
#endif
#endif //X86_SYSV_TOOLS_INFO_H