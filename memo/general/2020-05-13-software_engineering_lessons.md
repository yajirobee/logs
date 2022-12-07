---
layout: memo
title: Lessons of Software Engineering learned from my experience
---

Lessons and best practices from my experience. This is a living document.

# Protocol
- Generally avoid custom serialization format
- A receiver of a message should have a way to verify that the message was derivered correctly
- Data format should have a distinct and explicit version
- Sometimes completeness of specification should be compromised to take easiness of implementation
  - [Worse is Better](https://www.dreamsongs.com/RiseOfWorseIsBetter.html)
  - > There is never enough time to do it right, but there is always enough time to do it over.

# Metrics / Monitoring
- Collect all metrics you come up with as long as performance, space, cost, privacy and security allow
- Don't start an experiment without a hypothesis
- Understand where a metric come from before using it
  - Be aware whether the metric is leading or lagging indicator
  - [Active Benchmarking](https://www.brendangregg.com/activebenchmarking.html)

# Communications
- Poor communication makes more tasks
