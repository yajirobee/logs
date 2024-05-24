---
layout: memo
title: Kotlin cheatsheet
---

# Coroutine
- Default buffer size of buffered channel is [64](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.channels/-channel/-factory/-b-u-f-f-e-r-e-d.html).

- Await for completion of [CompletableFuture](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/concurrent/CompletableFuture.html) without blocking thread
use [await()](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.future/await.html)

## Links
- [KEEP: suspending functions](https://github.com/Kotlin/KEEP/blob/master/proposals/coroutines.md#suspending-functions)
- [Java agent to detect blocking calls from non-blocking threads.](https://github.com/reactor/BlockHound)

# Use multiple resources
```kotlin
class Resources : AutoCloseable {
  val resources = mutableListOf<AutoCloseable>()

  fun <T: AutoCloseable> T.use(): T {
    resources += this
    return this
  }

  override fun close() {
    var exception: Exception? = null
    resources.reversed().forEach { resource ->
      try {
        resource.close()
      } catch (closeException: Exception) {
        if (exception == null) {
          exception = closeException
        } else {
          exception.addSuppressed(closeException)
        }
      }
    }
    if (exception != null) throw exception
  }
}

inline fun <T> withResources(block: Resources.() -> T): T = Resources().use(block)

withResources {
  val connection = getConnection().use()
  val statement = connection.createStatement().use()
  val resultSet = statement.executeQuery(sql).use()
  while (resultSet.next()) { ... }
}
```

reference: [Is there standard way to use multiple resources?](https://discuss.kotlinlang.org/t/is-there-standard-way-to-use-multiple-resources/2613)

# Links
- [Playground](https://play.kotlinlang.org/)
