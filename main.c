#include <stdio.h>
#include <stdalign.h>
#include "info.h"
#include "min.h"

int main(void){
    unsigned L1_cache_size_info = xsti_cache_size(1);
    unsigned L2_cache_size_info = xsti_cache_size(2);
    unsigned L3_cache_size_info = xsti_cache_size(3);
    printf("L1 size info = %u, L2 size info = %u, L3 size info = %u\n", L1_cache_size_info, L2_cache_size_info, L3_cache_size_info);

    unsigned int L1_cache_size = get_cache_line_size(1);
    unsigned int L2_cache_size = get_cache_line_size(2);
    unsigned int L3_cache_size = get_cache_line_size(3);
    printf("L1 size = %u, L2 size = %u, L3 size = %u\n", L1_cache_size, L2_cache_size, L3_cache_size);

    test(31);

    unsigned int logical_cores_count_1 = cpu_topology_get_logical_cores();
    unsigned int logical_cores_count_2 = cpu_topology_get_logical_cores();
    unsigned int logical_cores_count_3 = cpu_topology_get_logical_cores();
    printf("Logical cores 1 = %u\n", logical_cores_count_1);
    printf("Logical cores 2 = %u\n", logical_cores_count_2);
    printf("Logical cores 3 = %u\n", logical_cores_count_3);
    _Alignas(AVX2_ALIGNEMENT) long long longs[] = {1333, 3123, 3, 122};
    long long *min_ptr = avx2_find_min(longs);
    printf("The minimum is %lli\n", *min_ptr);
}