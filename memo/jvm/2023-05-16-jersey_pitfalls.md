---
layout: memo
title: Jersey pitfalls
---

# 404 when a path of request matches with multiple resource classes
Resource classes should have unique pathes as much as possible to get around the issue of request matching.
If it's difficult to cleanly separate resource classes, sub resource should be used.

- [Matching Requests to Resource Methods – Fails to match some straightforward case](https://github.com/jakartaee/rest/issues/904)
- Jakarta RESTful Web Services Specification - request matching
  - [github](https://github.com/jakartaee/rest/blob/master/jaxrs-spec/src/main/asciidoc/chapters/resources/_mapping_requests_to_java_methods.adoc)
  - [web (Jakarta EE9 (3.0))](https://jakarta.ee/specifications/restful-ws/3.0/jakarta-restful-ws-spec-3.0#request_matching)
