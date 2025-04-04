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

- [java 17 Networking Properties](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/net/doc-files/net-properties.html)

`sun.net.inetaddr.ttl` / `sun.net.inetaddr.negative.ttl` are the legacy properties.
They have the same meaning as `networkaddress.cache.ttl` / `networkaddress.cache.negative.ttl`, but preferred way is `networkaddress.cache.ttl` / `networkaddress.cache.negative.ttl`.

- [java 8 Networking Properties](https://docs.oracle.com/javase/8/docs/technotes/guides/net/properties.html)

# Monitoring
## inspect system properties of running jvm process
```
jcmd <pid> VM.system_properties
```

- [jcmd java 17](https://docs.oracle.com/en/java/javase/17/docs/specs/man/jcmd.html)

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
- [async-profiler](https://github.com/async-profiler/async-profiler)
- [hprof-slurp](https://github.com/agourlay/hprof-slurp)

# Memory management
## GC
- [Garbage-First (G1) Garbage Collector](https://docs.oracle.com/en/java/javase/17/gctuning/garbage-first-g1-garbage-collector1.html)
- [G1GC Tuning](https://www.oracle.com/technical-resources/articles/java/g1gc.html)

## Direct Buffer & Buffer Pool
> Given a direct byte buffer, the Java virtual machine will make a best effort to perform native I/O operations directly upon it. That is, it will attempt to avoid copying the buffer's content to (or from) an intermediate buffer before (or after) each invocation of one of the underlying operating system's native I/O operations.

From [Direct vs. non-direct buffers](https://docs.oracle.com/javase/8/docs/api/java/nio/ByteBuffer.html)

- [Understanding Java Buffer Pool Memory Space](https://www.fusion-reactor.com/blog/understanding-java-buffer-pool-memory-space/)

# Variable Handles
- [JEP 193: Variable Handles](https://openjdk.org/jeps/193)
- [java.lang.invoke.VarHandle](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/lang/invoke/VarHandle.html)
- [JEP 193: Variable Handles について](https://qiita.com/yoshioterada/items/319ed0dec4b847d2b1ed)

# Check class file major version
```sh
javap -verbose JavaClassNameOrPath | grep major
```

# Libraries and tools
Libraries I commonly use for java projects.

- [micrometer](https://micrometer.io/) - application metrics
- [failsafe](https://failsafe.dev/) - falult tolerance and resilience
- [bucket4j](https://github.com/bucket4j/bucket4j) - rate limiting
- [HikariCP](https://github.com/brettwooldridge/HikariCP) - JDBC connection pool
- [jOOQ](https://www.jooq.org/) - DSL for type safe SQL construction
- [flyway](https://flywaydb.org/) - DB version control

# Commands
- Check installed JVMs
```sh
/usr/libexec/java_home -V
```

# References
- [Oracle Java Standart Edition Documentation](https://docs.oracle.com/en/java/javase/index.html)
- [Java Lnaguage Changes](https://docs.oracle.com/en/java/javase/21/language/java-language-changes.html)
- [java 11 Command Reference](https://docs.oracle.com/en/java/javase/11/tools/java.html)
