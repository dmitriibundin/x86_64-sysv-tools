#ifndef X86_SYSV_TOOLS_INFO_H
#define X86_SYSV_TOOLS_INFO_H

#ifdef __cplusplus
extern "C" {
#endif

//Namespace xsti -- x86_sysv_tools_info

enum xsti_cpu_vendor{
    CPU_VENDOR_INTEL = 0,

    CPU_VENDOR_UNKNOWN = -1
};

enum xsti_cpu_vendor xsti_cpu_vendor(void);

//For the 2nd level TLB the associativity ways
//are incorrectly reported on Kaby Lake as
//6-ways set associative, but actually 12-ways
struct xsti_tlb {
    unsigned      entries,
                  page_size,
                  associativity;
    unsigned char data: 1,
                  instruction: 1;
};

/**
 * Given a level_from and level_to parameters collects information
 * regarding TLB caches starting from level_from (inclusive) up to
 * level_to (exclusive) and stores the result into arguments passed in
 * as an ellipsis.
 * 
 * For each requested TLB cache level 2 parameters is required
 * to be passed in the ellipsis:
 * 
 *  size_t *sz - a pointer to a size of struct xsti_tlb* array used for a given TLB cache level.
 *               It should contain the size of struct xsti_tlb* array used for a particular TLB cache
 *               level prior to the function call. The value contained in the object pointed to by sz
 *               after the function call reflects the actual number of struct xsti_tlb* entries
 *               that were initialized by the function call
 * 
 *  struct xsti_tlb* - an array of a struct xsti_tlb with the size passed in 
 *                     the previous parameter
 * 
 * For example:
 * 
 * struct xsti_tlb l2_tlb[3];
 * size_t l2_tlb_entries = sizeof l2_tlb / sizeof(struct xsti_tlb);
 * 
 * struct xsti_tlb l3_tlb[5];
 * size_t l3_tlb_entries = sizeof l3_tlb / sizeof(struct xsti_tlb);
 * 
 * strict xsti_tlb l4_tlb[27];
 * size_t l4_tlb_entries = sizeof l4_tlb / sizeof(struct xsti_tlb);
 * 
 * int result = xsti_get_tlb(2, 5,
 *                           &l2_tlb_entries, l2_tlb,
 *                           &l3_tlb_entries, l3_tlb,
 *                           &l4_tlb_entries, l4_tlb);
 * returns:
 *  0 - on success
 * -1 - on error
 */

//Probably accept varargs as {size_t, struct xsti_tlb*}
int xsti_get_tlb(size_t level_from, size_t level_to, ...);

struct xsti_cpu_cache {
    unsigned    number_of_sets,
                line_size,
                physical_line_partitions,
                associativity_ways, 
                total_cache_size;
};

struct xsti_cpu_cache xsti_cache_size(unsigned cache_level);

unsigned xsti_cache_line_size(void);

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