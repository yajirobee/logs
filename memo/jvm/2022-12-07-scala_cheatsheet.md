---
layout: memo
title: Scala cheatsheet
---

# Specify interface implemented by lambda explicitly
```scala
// differentiate it from Supplier[Boolean]
{ () => true }: java.util.function.BooleanSupplier
```
