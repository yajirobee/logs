---
layout: blog
title: "Read Book: Systems Performance 2nd edition"
tags: Book
---

Notes while reading [Systems Performance: Enterprise and the Cloud, 2nd Edition](https://www.brendangregg.com/blog/2020-07-15/systems-performance-2nd-edition.html).
This is still WIP as I'm still reading the book.

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
  - **> have an instinct about time and reasonable expectation for latency from different sources**
- 2.3.3 Trade Offs
  - good/fast/cheap "pick two" trade-off
  - in most cases, good and cheap are picked
  - That choice can become problematic when architecture and tech stacks choices don't allow good performance.
- 2.3.4 Tuning Efforts
  - **> Performance tuning is most effective when done closest to where the work is performed.**
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
  - **> The more you learn about systems, the more unknown-unknowns you become aware of.**
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
  - **> The best performance wins are the result of eliminating unnecessary work.**
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
