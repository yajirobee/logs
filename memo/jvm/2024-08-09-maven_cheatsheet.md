---
layout: memo
title: maven cheatsheet
---

# Configuration
[Configuration maven](https://maven.apache.org/configure.html#mvn-maven-config-file)

- `.mvn/maven.config` file
It can define the options for your build on a per project base

# Repository
- [Repository Order](https://maven.apache.org/guides/mini/guide-multiple-repositories.html#repository-order)

effective settings -> local effective build POM -> effective POMs from dependency path to the artifact

# Settings
[Settings Reference](https://maven.apache.org/settings.html)

> The settings element in the settings.xml file contains elements used to define values which configure Maven execution in various ways

- environment variables: e.g. `${env.HOME}`
- profiles
> If a profile is active from settings, its values will override any equivalently ID'd profiles in a POM or profiles.xml file.

# Inspect lifecycles
Use [buildplan plugin](https://www.mojohaus.org/buildplan-maven-plugin/usage.html)

```sh
mvn fr.jcgay.maven.plugins:buildplan-maven-plugin:list
```

# Trouble shooting
## jenv settings are ignored
```sh
# set JAVA_HOME by jEnv
jenv enable-plugin export
```
or
```sh
jenv exec mvn ...
```
