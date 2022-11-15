---
layout: memo
title: JVM monitoring cheatsheet
---

# Native Memory Tracking
enable NMT by `-XX:NativeMemoryTracking=[summary | detail]` and execute

```
jcmd <pid> VM.native_memory [summary | detail | baseline | summary.diff | detail.diff | shutdown] [scale= KB | MB | GB]
```

- [java11 native memory tracking](https://docs.oracle.com/en/java/javase/11/vm/native-memory-tracking.html#GUID-710CAEA1-7C6D-4D80-AB0C-B0958E329407)

# Count Theads
Check the Safe Memory Reclamation (SMR) info of thread dump. `length` is count of non-JVM internal threads.

```
Threads class SMR info:
_java_thread_list=0x00007f7d40428050, length=252, elements={
```

> Note: Enabling NMT causes a 5% -10% performance overhead.
