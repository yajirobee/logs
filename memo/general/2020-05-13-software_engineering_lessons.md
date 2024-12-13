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
- Use scale-agnostic programming abstraction properly
  - [Scale Agnosticism](https://queue.acm.org/detail.cfm?id=3025012)

# Protocol
- Generally avoid custom serialization format
- A receiver of a message should have a way to verify that the message was derivered correctly
- Data format should have a distinct and explicit version
- Sometimes completeness of specification should be compromised to take easiness of implementation
  - [Worse is Better](https://www.dreamsongs.com/RiseOfWorseIsBetter.html)
  - > There is never enough time to do it right, but there is always enough time to do it over.
- Implementation detail can eventually be an (implicit) interface
  - [Hyrum's Law](https://www.hyrumslaw.com/)
  - > For example, an interface may make no guarantees about performance, yet consumers often come to expect a certain level of performance from its implementation.

# Metrics / Monitoring
- Collect all metrics you come up with as long as performance, space, cost, privacy and security allow
- Don't start an experiment without a hypothesis
- Understand where a metric come from before using it
  - Be aware whether the metric is leading or lagging indicator
  - [Active Benchmarking](https://www.brendangregg.com/activebenchmarking.html)
- Think of the most important problem first. Do not start from where it is most convenient to look.
  - Beware of [Streetlight effect](https://en.wikipedia.org/wiki/Streetlight_effect)
  - > A policeman sees a drunk man searching for something under a streetlight and asks what the drunk has lost. He says he lost his keys and they both look under the streetlight together. After a few minutes the policeman asks if he is sure he lost them here, and the drunk replies, no, and that he lost them in the park. The policeman asks why he is searching here, and the drunk replies, "this is where the light is".

# Communications
- Poor communication makes more tasks
- Do not just dispense ideas. Let person who trackles on a problem to own ideas.
  - > develop problems, and to do a really good job of articulating them, rather than trying to pitch solutions. There are often multiple ways to solve a problem, and picking the right one is letting someone own the solution. (from [Building and operating a pretty big storage system called S3](https://www.allthingsdistributed.com/2023/07/building-and-operating-a-pretty-big-storage-system.html))
- [Weak and strong team concepts.](https://lethain.com/weak-and-strong-team-concepts/)

# Learning
- Lead to "approach" goal orientation rather than "avoidance".
  - > The "approach" goal orientation involves wanting to do well, and this engenders positive and effective learning behaviors: working hard, seeking help, and trying new challenging topics. In contrast, the “avoidance” goal orientation involves avoiding failure. This leads to negative and ineffective behaviors: disorganized study, not seeking help, anxiety over performance, and avoiding challenge. It is important that learners can make mistakes without severe penalties if they are to be directed towards "approach" rather than "avoidance." (from [10 Things Software Developers Should Learn about Learning](https://cacm.acm.org/research/10-things-software-developers-should-learn-about-learning/))
