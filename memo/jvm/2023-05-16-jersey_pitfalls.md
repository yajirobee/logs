---
layout: memo
title: Jersey pitfalls
---

# Multiple resource classes must not have the same @Path
Resource classes should have unique pathes as much as possible to get around the issue of request matching.
If it's difficult to cleanly separate resource classes, sub resource should be used.

- [Matching Requests to Resource Methods – Fails to match some straightforward case](https://github.com/jakartaee/rest/issues/904)
- [jaxrs spec of resource matching](https://github.com/jakartaee/rest/blob/master/jaxrs-spec/src/main/asciidoc/chapters/resources/_mapping_requests_to_java_methods.adoc)
