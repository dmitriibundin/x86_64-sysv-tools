#include <stdio.h>
#include <stdalign.h>
#include <string.h>
#include "info.h"
#include "min.h"

int main(void){
    enum xsti_cpu_vendor vendor = xsti_cpu_vendor();
    printf("Vendor = %d\n", vendor);
    struct xsti_cpu_cache L1_cache_info = xsti_cache_size(1);
    struct xsti_cpu_cache L2_cache_info = xsti_cache_size(2);
    struct xsti_cpu_cache L3_cache_info = xsti_cache_size(3);

    printf("L1 sets = %u, L1 line size = %u, L1 partitions = %u, L1 associativity = %u, L1 total size = %u\n",
                    L1_cache_info.number_of_sets,
                    L1_cache_info.line_size,
                    L1_cache_info.physical_line_partitions,
                    L1_cache_info.associativity_ways,
                    L1_cache_info.total_cache_size);

    printf("L2 sets = %u, L2 line size = %u, L2 partitions = %u, L2 associativity = %u, L2 total size = %u\n",
                    L2_cache_info.number_of_sets,
                    L2_cache_info.line_size,
                    L2_cache_info.physical_line_partitions,
                    L2_cache_info.associativity_ways,
                    L2_cache_info.total_cache_size);

    printf("L3 sets = %u, L3 line size = %u, L3 partitions = %u, L3 associativity = %u, L3 total size = %u\n",
                    L3_cache_info.number_of_sets,
                    L3_cache_info.line_size,
                    L3_cache_info.physical_line_partitions,
                    L3_cache_info.associativity_ways,
                    L3_cache_info.total_cache_size);

    unsigned int L1_cache_size = get_cache_line_size(1);
    unsigned int L2_cache_size = get_cache_line_size(2);
    unsigned int L3_cache_size = get_cache_line_size(3);
    printf("L1 size = %u, L2 size = %u, L3 size = %u\n", L1_cache_size, L2_cache_size, L3_cache_size);

    unsigned logical_cores_count_1_info = xsti_logical_cores();
    unsigned logical_cores_count_2_info = xsti_logical_cores();
    unsigned logical_cores_count_3_info = xsti_logical_cores();
    printf("Logical core 1 info = %u\n", logical_cores_count_1_info);
    printf("Logical core 2 info = %u\n", logical_cores_count_2_info);
    printf("Logical core 3 info = %u\n", logical_cores_count_3_info);

    struct xsti_frequencies freqs = xsti_frequencies();
    printf("Base frequency = %u MHz, max frequency = %u MHz, bus frequency = %u MHz\n",
            freqs.base_cpu_frequency,
            freqs.max_cpu_frequency,
            freqs.bus_frequency);
    unsigned int logical_cores_count_1 = cpu_topology_get_logical_cores();
    unsigned int logical_cores_count_2 = cpu_topology_get_logical_cores();
    unsigned int logical_cores_count_3 = cpu_topology_get_logical_cores();
    printf("Logical cores 1 = %u\n", logical_cores_count_1);
    printf("Logical cores 2 = %u\n", logical_cores_count_2);
    printf("Logical cores 3 = %u\n", logical_cores_count_3);

    unsigned cache_line_size = xsti_cache_line_size();
    printf("Cache line size = %u bytes\n", cache_line_size);

    char buf[64];
    memset(buf, '\0', sizeof(buf));
    unsigned xsti_cpu_brand_string_result = 0;
    if((xsti_cpu_brand_string_result = xsti_cpu_brand_string(buf, sizeof(buf))) == 0){
        printf("CPU brand string = %s\n", buf);
    } else {
        printf("The buffer is required to have at least %u bytes\n", xsti_cpu_brand_string_result);
    }

    _Alignas(AVX2_ALIGNEMENT) long long longs[] = {1333, 3123, 3, 122};
    long long *min_ptr = avx2_find_min(longs);
    printf("The minimum is %lli\n", *min_ptr);
}

struct ints_struct {
    int a, b;
    long long c;
};

struct ints_struct get_struct_t(void){
    return (struct ints_struct){10, 20, 300000000000L};
}
