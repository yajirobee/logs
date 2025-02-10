---
layout: blog
title: "Read Book: Systems Performance 2nd edition"
tags: Book
---

Notes while reading [Systems Performance: Enterprise and the Cloud, 2nd Edition](https://www.brendangregg.com/blog/2020-07-15/systems-performance-2nd-edition.html).
This is still WIP as I'm still reading.

I read the 1st edition 9 years ago. It turns out that the 2nd edition has so many updates since the 1st including more coverage for Linux rather than Solaris and Cloud computing. I recommend to read it even if you've read the 1st edition.

<!--end_excerpt-->

# 1 Introduction
- 1.1 Systems Performance
  - > Systems performance studies the performance of an entire computer system, including all major software and hardware components. Anything in the data path, from storage devices to application software, is included, because it can affect performance. For distribnuted systems this means multiple servers and applications.
  - Write a diagram of system showing the data path
  - understand relationships between components and don't overlook entire areas
- 1.2 Roles
  - > For some performance issues, finding the root cause or contributing factors requires a cooperative effor from more than one team.
- 1.5.1 Subjectivity
  - Performance is often subjective
- 1.5.2 Complexity
  - > soling complex performance issue often requires a holistic approach
- 1.5.3 Multiple Performance Issues
  - > the real task isn't finding an issue; it's identifying which issue or issues matter the most
- 1.10 Methodologies
  - > Without a methodology, a methodology, a perforamnce investigation can turn into a fishing expedition

# 2 Methodologies
- experienced performance engineers understand which metrics are important and when they point to an issue, and how to use them to narrow down an investigation
- 2.3.1 Latency
  - > single word "latency" can be ambiguous, it is best to include qualifying terms
- 2.3.2 Time Scales
  - > **have an instinct about time and reasonable expectation for latency from different sources**
- 2.3.3 Trade Offs
  - good/fast/cheap "pick two" trade-off
  - in most cases, good and cheap are picked
  - That choice can become problematic when architecture and tech stacks choices don't allow good performance.
- 2.3.4 Tuning Efforts
  - > **Performance tuning is most effective when done closest to where the work is performed.***
  - > Operating system performance analysis can also identify application-level issues, not just OS-level issues
- 2.3.6 When to stop analysis
  - when major problems are solved
  - potential ROI is less than the cost of analysis
- 2.3.7 Point-in-time reccommendataions
  - **Peformance recommendataions are valid only at a specific point in time.**
  - workload change, software/hardware change changes performance characteristics.
- 2.3.9 Scalablity
  - fast degradation profile examples: memory load, i.e. moving memory pages to disk, Disk I/O on high queue depth
  - slow degradation profile examples: CPU load
- 2.3.11 Utilization
  - Time-based utilization
    - saturation may not happen at 100% time-based utilization depending on capability of parallelism
  - Capacity-based utilization
- 2.3.15 Known-Unknowns
  - > **The more you learn about systems, the more unknown-unknowns you become aware of.**
  - which are then known-unknowns that you can check on
- 2.4 Perspectives
  - Resource analysis (bottom-up) vs workload analysis (top-down)
    - typical metrics for resource analysis
      - IOPS
      - Throughput (e.g. bytes per second)
      - Utilization
      - Saturation
    - typical metrics for workload analysis
      - Throughput (e.g. transactions per second)
      - Latency
- 2.5 Methodology
  - Resist temptation of anti-methods, start from more logical approaches like problem statement, scientific method, USE method
- 2.5.3 Blame-Someone-Else Anti-Method
  - Be aware that use of this method may waste time and effort of other teams.
  - Lack of data leading to a hypothesis results in this method.
- 2.5.9 **The USE Method**
  - measure utilization, saturation and errors (USE) for every resource
  - listing resources and finding metrics are possibly time consuming for the first time, but it should be much faster next time
- 2.5.10 RED Method
  - For every service, check Request rate, errors and duration (RED)
  - USE and RED methods are complementary: USE method for machine health, RED method for user health
- 2.5.11 Workload Characterization
  - > **The best performance wins are the result of eliminating unnecessary work.**
- 2.6 Modeling
  - It’s critical to know where knee points exist and what resource is a bottleneck for that performance behavior. It impacts the system architecture design decision.
- 2.8.5 Multimodal Distributions
  - Average is useful only for unimordal distributions. ask what is the distribution before using average
  - Latency metrics are often bimodal

# 3 Operating Systems
- 3.2.5 Clock and Idle
  - `clock()` routine: updating the system time, maintaining CPU statistics, etc
    - executed from a timer interrupt
    - each execution is called a `tick`
- 3.2.9 Schedulers
  - prioritize I/O-bound workloads over CPU-bound workloads
- 3.3 Kernels
  - Kernel differences: file system support, system calls, network stack architecture, real-time support, scheduling algorithms for CPUs, disk I/O, networking
- 3.4.1 Linux Kernel Developments
  - Multi-queue block I/O scheduler is default in 5.0 and classic schedulers like CFQ, deadline have been deleted

# 5 Applications
- 5.1 Objectives
  - Better observability enables to see and eliminate unnecessary work and to better understanding and tune active work.
    - It should be a major factor to choose applications / middlewares / languages and runtimes.
- 5.2.5 Concurrency and Parallelism
  - Linux mutex is implemented in [3 paths](https://www.kernel.org/doc/Documentation/locking/mutex-design.txt)
  - Hash table of locks is a design option to limit number of locks for fine grained locking
    - Avoid CPU overheads for the creation and destruction of the lock too
  - false sharing - two CPUs updating different locks in the same cache line
    - encounter cache coherencey overhead
- 5.3.1 Compiled Languages
  - gcc applies some optimizations even at `-O0`
- 5.4 Methodology
  - CPU / off-CPU profiling and thread state analysis can reveal how compute resources are used
  - Distributed tracing is suggested as the last resort
  - It appears the methodologies are described from the point of view of engineers who don't have much context about application.
    - When application developpers work on analysis, the order to try methodologies may change
- 5.4.2 Off-CPU Analysis
  - off-CPU sampling comes with with major overhead
    - It must sample the pool of threads rather than the pool of CPUs
- 5.5 Observability Tools
  - [BPF Compiler Collections (BCC)](https://github.com/iovisor/bcc/tree/master)
  - [profile(8)](https://github.com/iovisor/bcc/blob/master/tools/profile.py)
  - offcpu(8) - [Off-CPU flame graphs](https://www.brendangregg.com/FlameGraphs/offcpuflamegraphs.html)

# 6 CPUs
- 6.3.8 Utilization
  - > The measure of CPU utilization spans all clock cycles for eligible activities, including memory stall cycles.
    - High CPU utilization doesn't immediately mean CPU bound workload.
    - A CPU may be utilized for stalls waiting for memory I/O.
    - High CPU & high IPC suggests CPU bound workload.
- 6.4.1 Hardwares
    - Handling of TLD misses is processor-dependent
      - > Newer processors can service TLB misses in hardware.
- 6.4.2 Software
  - In completely fair scheduler (CFS), tasks are managed on a red-black tree keyed from the task CPU time.
- 6.5.3 Workload Characterization
  - High system time (time spent in kernel) may be futher understood by the syscall and interrupt rate.
  - > I/O bound workloads have high system time, syscalls and higher voluntary context switches as threads block waiting for I/O.
- 6.5.4 Profiling
  - > 99 Hertz is used to avoid lock-step sampling that may occur at 100 Hertz, which would produce a skewed profile.
- 6.6.1 uptime
  - Since 1993 on Linux, load averages show system-wide demand: CPUs, disks and other resources, not only CPU demand.
    - [The average is an exponentially damped moving average](https://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html).
  - Pressure Stall Information (PSI) was added in Linux 4.20
    - available on `/proc/pressure/cpu`
    - shows saturation of CPU, memory and I/O
    - The average shows the percent of time something was stalled on a resource
- 6.6.6 top
  - CPU usage of top(1) itself can be significant
    - due to the system calles to read /proc, open(2), read(2), close(2), over many processes.
- 6.6.13 perf
  - Since Linux 5.8, CPU flame graphs can be generated from `perf.data`
    ```sh
    perf record -F 99 -a -g -- sleep 10
    perf script report flamegraph
    ```
- 6.6.21 Other Tools
  - > GPU profiling is different from CPU profiling, as CPUs do not have a stack trace showing code path ancestry.
  - > Profilters instead can instrument API and memory transfer calls and their timing.
- 6.7.2 SUbsecond-Offset Heat Map
  - > CPU activity is typically measured in microseconds or milliseconds; reporting this data as averages over an entire second can wipe out useful information.
- 6.9.7 Exclusive CPU Sets
  - cpusets of Linux allows to make a set of CPUs exclusive for processes.

# 7 Memory
- 7.1 Terminology
  - Swapping (in Linux): anonymous paging to the swap device (the transfer of swap pages)
- 7.2.1 Virtual Memory
  - Oversubscribe vs overcommit
    - oversubscribe: allows bounded allocation more than main memory
      - e.g. the size of main memory + swap device
    - overcommit (Linux term): allows unbounded memory allocation
- 7.2.2 Paging
  - File system paging is caused by read/write of pages in memory-mapped files.
    - normal behavior for applications that use mmap(2) and file systems that use the page cache.
  - Page-out: a page was moved out of memory.
    - may or may not include a write to a storage device
  - Anonymous page-outs: requre moving the data to the physical swap devices.
- 7.2.3 Demand Paging
  - Minor fault: physical memory mapping can be satisfied from another page in memory
    - e.g. memory growth of the process, mapping to another existing page, such as reading a page from a mapped shared library.
  - Major fault: require storage device access
- 7.2.5 Process Swapping
  - > Linux systems do not swap processes at all and rely only on paging.
- 7.2.9 Shared Memory
  - Proportional set size (PSS): private memory + shared memory divided by the number of users
- 7.3.1 Hardware
  - Column address strobe (CAS): time between sending a memory module the desired address (column) and when the data is available to be read.
    - depends on type of memory, e.g. DDR4, 5
    - > For memory I/O transfers, this latency may occur multiple times for a memory bus (e.g., 64 bits wide) to transfer a cache line (e.g., at 64 bytes wide).
    - There are also other latencies involved with the CPU and MMU
- 7.3.2 Software
  - swappiness: the degree to which the system should favor freeing memory from the page cache instead of swapping
    - 0 means always prefer freeing the page cache
    - control the balance how much warm file system cache should be preserved
  - Without swap, there is no paging grace period.
    - application hits OOM error or OOM killer terminates it.
  - Linux uses the buddy allocator for managing pages
    - Multiple free lists for different sized memory allocations
  - Page Scanning: on linux, the page-out daemon is called "kswapd"
    - Scans LRU page lists of inactive and active memory to free pages
- 7.3.3 Process Virtual Address Space
  - For simple allocators, free(3) does not return memory to OS
    - memory is kept to serve future allocations
    - Process resident memory can only grow, which is normal
  - Memory allocators
    - glibc: behavior depends on allocation request size.
      - small allocations are served from bins of memory, buddy-like algorithm
      - large allocations can use a tree lookup to find space efficiently
    - jemalloc: uses techniques such as multiple arenas, per-thread caching, and small object slabs
      - improve scalability, reduce memory fragmentation
- 7.4.2 USE Method
  - > Saturation: The degree of page scanning, paging, swapping, and Linux OOM killer sacrifices performed, as measures to relieve memory pressure.
  - > Historically, memory allocation errors have been left for the applications to report
- 7.5.4 sar (system activity reporter)
  - > To understand these in deeper detail, you may need to use tracers to instrument memory tracepoints and kernel functions, such as perf(1) and bpftrace
  - %vmeff: measure of page reclaim efficiency
    - High means pages are successfully stolen from the inactive list
    - Low means the system is struggling
    - The man page describes near 100% as high, less than 30% as low
- 7.6.2 Multiple Page Sizes
  - Transparent huge pages (THP): use huge pages by automatically promoting and demoting normal pages to huge
    - application doesn't need to specify huge pages

# 8 File Systems


# 11 Could Computing
- 11.1.3 Capacity Planning
  - Cloud computing makes people free from strict capacity planning to purchase proper hardwares.
    - For growing startups, it's particularlly difficult to estimate because demand changes more aggressively and the pace of code changes is high.
- 11.1.6 Orchestration (Kubernetes)
  - > Performance challenges in Kubernetes include scheduling, and network performance, as extra components are used to implement container networking and load balancing.
- 11.2.2 Overhead
  - > Understanding when and when not to expect performance overhead from virtulization is important
  - The guest applications execute directly on the processors, so CPU-bound applications may experience almost the same performance as a bare-metal system.
  - > CPU overheads may be encountered when making privileged processor calls, accessing hardware, and mapping main memory
  - The mapping from guest virtual memory to host physical memory is cached in the TLB.
  - The storage architecture may also lead to double caching, i.e. caching on both host and guest.
- 11.2.3 Resource Controls
  - > A guest's CPU usage is typically opaque to the hypervisor, and guest kernel thread priorities cannot typically be seen or respected.
  - > In the Amazon EC2 cloud, network I/O and disk I/O to network-attached devices are throttled to quotas using external systems.
- 11.2.4 Observability
  - > From the guest, physical resource usage may not be observable at all.
  - vmstats(8) command includes CPU percent stolen (st). It shows CPU time not available to the guest. It may be consumed by other tenants or other hypervisor functions.
  - Disk and network resource contention may be identified by careful analysis of I/O patterns and latency outliers.
