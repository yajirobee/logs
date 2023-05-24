---
layout: memo
title: JVM cheatsheet
---

# Settings
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

# Gradle
## CLI options
- execute only test case of nested subclass
```sh
$ ./gradlew test --tests "some.package.class\$subclass"
```

- specify args
```sh
$ ./gradlew run --args="-h"
```

## Modify JVM options
Use [Gradle Properties](https://docs.gradle.org/current/userguide/build_environment.html). e.g.

```
org.gradle.jvmargs=-Xmx1024m -XX:MaxMetaspaceSize=256m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
```

## Using Plugins
[Plugins DSL](https://docs.gradle.org/current/userguide/plugins.html#sec:plugins_block) is newer and convenient way to
declare plugin dependencies. It looks up [Gradle plugin portal](https://plugins.gradle.org/) for core and community plugins.
If plugins DSL cannot be used due to the restrictions, you need to use [Legacy Plugin Application](https://docs.gradle.org/current/userguide/plugins.html#sec:old_plugin_application).

## [Initialization Scripts](https://docs.gradle.org/current/userguide/init_scripts.html)
[Applying plugin by id doesn't work](https://github.com/gradle/gradle/issues/1322). It should be added by type. e.g.

```kotlin
import bloop.integrations.gradle.BloopPlugin

initscript {
    repositories {
        mavenCentral()
    }

    dependencies { classpath("ch.epfl.scala:gradle-bloop_2.12:1.6.0") }
}

allprojects {
    apply<BloopPlugin>()
}
```

## [Default Imports](https://docs.gradle.org/current/userguide/writing_build_scripts.html#script-default-imports)

# References
- [java 11 Command Reference](https://docs.oracle.com/en/java/javase/11/tools/java.html#GUID-3B1CE181-CD30-4178-9602-230B800D4FAE)
