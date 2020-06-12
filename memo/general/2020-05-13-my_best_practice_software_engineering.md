---
layout: memo
title: My Best Practice of Software Engineering
---

Some best practices from my experience. This is a living document.

# Protocol
- Generally avoid custom serialization format
- A receiver of a message should have a way to verify that the message was derivered correctly
- Data format should have a distinct and explicit version
- Sometimes completeness of specification should be compromised to take easiness of implementation

# Metrics / Monitoring
- Collect every metrics you come up with as much as performance, cost and security allow
- Don't start an experiment without a hypothesis
- Understand where a metrics come from before using it
