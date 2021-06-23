---
layout: memo
title: Difficult software bugs I have experienced
---

Difficult and impressive bugs I've experienced.

# 2021
## `Result` returned wrong value
- Symptom: `Result` instance returned wrong value when it was used with coroutine.
- Related components: Kotlin (jvm) >= 1.5.0 < 1.5.30
- Root cause: [`Result` was wrapped twice](https://youtrack.jetbrains.com/issue/KT-46924)

# 2020
## Rarely failed to send HTTP response by chunked transfer encoding
- Symptom: Rarely jersey server sent incomplete http response when `ChunkedOutput` was used.
- Related components: jersey < 2.32
- Root cause: [Race condition of `ChunkedOutput`](https://github.com/eclipse-ee4j/jersey/issues/4493)

# 2019
## Sudden performance degradation of PostgreSQL
- Symptom: Suddenly DB response became very slow and didn't respond at all in the end.
- Related components: PostgreSQL 9.4, AWS RDS
- Root cause: [Exclusive lock on table extention](https://www.postgresql.org/message-id/20150329185619.GA29062@alap3.anarazel.de)
- Detail: 
<iframe src="https://www.slideshare.net/slideshow/embed_code/key/IDrdvr67oKY7Qp" 
 width="427" height="356" frameborder="0" marginwidth="0" marginheight="0" 
 scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen
> </iframe> 
<div style="margin-bottom:5px"> 
<strong> 
<a href="https://www.slideshare.net/secret/IDrdvr67oKY7Qp" title="20201008 Handling Performance Issues of Production Systems" target="_blank">20201008 Handling Performance Issues of Production Systems</a> 
</strong> from <strong>
<a href="https://www.slideshare.net/keisuke-suzuki" target="_blank">Keisuke Suzuki</a></strong> 
</div>
