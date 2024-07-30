---
layout: memo
title: gradle cheatsheet
---

# CLI options
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

# Dependencies
## Debug
> Gradle provides the built-in dependencyInsight task to render a dependency insight report from the command line. Dependency insights provide information about a single dependency within a single configuration. Given a dependency, you can identify the selection reason and origin.

- [Dependency Insights](https://docs.gradle.org/current/userguide/viewing_debugging_dependencies.html#dependency_insights)

# Features
- [Modeling library features](https://docs.gradle.org/current/userguide/feature_variants.html)

# Using Plugins
[Plugins DSL](https://docs.gradle.org/current/userguide/plugins.html#sec:plugins_block) is newer and convenient way to
declare plugin dependencies. It looks up [Gradle plugin portal](https://plugins.gradle.org/) for core and community plugins.
If plugins DSL cannot be used due to the restrictions, you need to use [Legacy Plugin Application](https://docs.gradle.org/current/userguide/plugins.html#sec:old_plugin_application).

## [Initialization Scripts](https://docs.gradle.org/current/userguide/init_scripts.html)
- [Applying plugin by id doesn't work](https://github.com/gradle/gradle/issues/1322)

It should be added by type. e.g.
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

- [Cannot import project in IntelliJ by unresolved reference error](https://github.com/gradle/gradle/issues/15946)

Use `.init.gradle.kts` extension for init scripts

## [Default Imports](https://docs.gradle.org/current/userguide/writing_build_scripts.html#script-default-imports)
