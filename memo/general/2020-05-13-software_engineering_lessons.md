---
layout: memo
title: Lessons of Software Engineering learned from my experience
---

Lessons and best practices from my experience. This is a living document.

# System Architecture
- Optimize for maintenance, not creation
- Software/System dependency is a way to leverage existing assets, but it also adds constraints.
  - impossible to pin versions of dependencies for good, e.g. security bugs, hardware support
  - version upgrade may break compatibilty

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
- Do not just dispense ideas. Let person who trackles on a problem to own ideas.
  - > develop problems, and to do a really good job of articulating them, rather than trying to pitch solutions. There are often multiple ways to solve a problem, and picking the right one is letting someone own the solution. (from [Building and operating a pretty big storage system called S3](https://www.allthingsdistributed.com/2023/07/building-and-operating-a-pretty-big-storage-system.html))

# Learning
- Lead to "approach" goal orientation instead of "avoidance".
  - > The "approach" goal orientation involves wanting to do well, and this engenders positive and effective learning behaviors: working hard, seeking help, and trying new challenging topics. In contrast, the “avoidance” goal orientation involves avoiding failure. This leads to negative and ineffective behaviors: disorganized study, not seeking help, anxiety over performance, and avoiding challenge. It is important that learners can make mistakes without severe penalties if they are to be directed towards "approach" rather than "avoidance." (from [10 Things Software Developers Should Learn about Learning](https://cacm.acm.org/research/10-things-software-developers-should-learn-about-learning/))
