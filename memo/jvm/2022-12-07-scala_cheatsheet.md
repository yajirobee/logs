---
layout: memo
title: Scala cheatsheet
---

# Scala 3

## Links
- [new features of Scala 3](https://docs.scala-lang.org/scala3/reference/other-new-features/index.html)
- [Direct-style Effects Explained](https://www.inner-product.com/posts/direct-style-effects/)

# Scala 2
## For comprehension
In Scala, for comprehension is a syntax sugar of a sequence of following methods
- foreach
  - e.g.
  ```scala
  for { item <- items } println(item)
  ```
- map
  - e.g.
  ```scala
  for { item <- items } yield item * 2
  ```
- flatMap
  - e.g.
  ```scala
  for {
    item1 <- items
    item2 <- otherItems
  } println(item)
  ```
- withFilter
  - e.g.
  ```scala
  for {
    item <- items
    if item == 0
  } println(item)
  ```

- [For comprehensions](https://docs.scala-lang.org/tour/for-comprehensions.html)

## Specify interface implemented by lambda explicitly
```scala
// differentiate it from Supplier[Boolean]
{ () => true }: java.util.function.BooleanSupplier
```
