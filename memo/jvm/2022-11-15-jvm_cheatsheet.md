---
layout: memo
title: JVM cheatsheet
---

# Settings
## Prepend options by environment variables
- `JDK_JAVA_OPTIONS` : used by `java` command
- [JAVA_TOOL_OPTIONS](https://docs.oracle.com/en/java/javase/17/troubleshoot/environment-variables-and-system-properties.html) : used by other tools as well
  - > this environment variable is examined at the time, that the JNI_CreateJavaVM function is called

## Select heap size by a percentage of available RAM
Use `-XX:MaxRAMPercentage` / `-XX:MinRAMPercentage` / `-XX:InitialRAMPercentage`

```
$ java -XX:+PrintFlagsFinal -version | grep RAMPercentage
   double InitialRAMPercentage                     = 1.562500                                  {product} {default}
   double MaxRAMPercentage                         = 25.000000                                 {product} {default}
   double MinRAMPercentage                         = 50.000000                                 {product} {default}
openjdk version "11.0.16.1" 2022-08-12
```

- [Reference](https://bugs.openjdk.org/browse/JDK-8186248)

## Container Awareness
[openjdk container awareness](https://developers.redhat.com/articles/2022/04/19/java-17-whats-new-openjdks-container-awareness#)

## Set the TTL for DNS Name Lookups
Use `networkaddress.cache.ttl` / `networkaddress.cache.negative.ttl`

- [java 11 Networking Properties](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/net/doc-files/net-properties.html)

# Monitoring
## Native Memory Tracking
Enable NMT by `-XX:NativeMemoryTracking=[summary | detail]` and execute

```
jcmd <pid> VM.native_memory [summary | detail | baseline | summary.diff | detail.diff | shutdown] [scale= KB | MB | GB]
```

- [java 11 Native Memory Tracking](https://docs.oracle.com/en/java/javase/11/vm/native-memory-tracking.html#GUID-710CAEA1-7C6D-4D80-AB0C-B0958E329407)

## Count Theads
Check the Safe Memory Reclamation (SMR) info of thread dump. `length` is count of non-JVM internal threads.

```
Threads class SMR info:
_java_thread_list=0x00007f7d40428050, length=252, elements={
```

> Note: Enabling NMT causes a 5% -10% performance overhead.

## Profiling
[async-profiler](https://github.com/async-profiler/async-profiler)

# Memory management
## GC
- [G1GC Tuning](https://www.oracle.com/technical-resources/articles/java/g1gc.html)

## Direct Buffer & Buffer Pool
> Given a direct byte buffer, the Java virtual machine will make a best effort to perform native I/O operations directly upon it. That is, it will attempt to avoid copying the buffer's content to (or from) an intermediate buffer before (or after) each invocation of one of the underlying operating system's native I/O operations.

From [Direct vs. non-direct buffers](https://docs.oracle.com/javase/8/docs/api/java/nio/ByteBuffer.html)

- [Understanding Java Buffer Pool Memory Space](https://www.fusion-reactor.com/blog/understanding-java-buffer-pool-memory-space/)

# References
- [Oracle Java Standart Edition Documentation](https://docs.oracle.com/en/java/javase/index.html)
- [Java Lnaguage Changes](https://docs.oracle.com/en/java/javase/21/language/java-language-changes.html)
- [java 11 Command Reference](https://docs.oracle.com/en/java/javase/11/tools/java.html)
