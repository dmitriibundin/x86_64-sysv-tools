#ifndef AVX2_MIN_H
#define AVX2_MIN_H

#define AVX2_ALIGNEMENT 32

long long * avx2_find_min(long long *);

unsigned int get_cache_line_size(unsigned int cache_level);

unsigned int cpu_topology_get_logical_cores(void);

#endif //AVX2_MIN_H