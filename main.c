#include <stdio.h>
#include <stdalign.h>
#include <string.h>
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

struct test{
    unsigned long a;
    char *b;
    unsigned long c;
};

struct test parse_struct(unsigned long l){
    return (struct test){.a = 10, .b = "abc", .c = 10 + l};
}

struct test get_struct(void){
    return (struct test){.a = 10, .b = "abc", .c = 20};
}

struct xsti_frequencies get_freqs(void){
    return (struct xsti_frequencies){10, 20, 30};
}

struct t{
    int a;
    int b;
};

int sum(struct t t){
    return t.a + t.b;
}

struct test *get_struct2(struct test *tst){
    struct test tmp = {.a = 10, .b = "abc", .c = 20};
    *tst = tmp;
    return tst;
}

struct small_struct{
    unsigned long a;
    unsigned long b;
};

struct small_struct get_small_struct(void){
    return (struct small_struct){.a = 10, .b = 20};
}