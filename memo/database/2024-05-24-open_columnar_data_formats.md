---
layout: memo
title: Open columnar data formats
---

# Parquet
- [File format](https://parquet.apache.org/docs/file-format/)
- [Thrift definition](https://github.com/apache/parquet-format/blob/master/src/main/thrift/parquet.thrift)

# ORC
- [ORC Specification v1](https://orc.apache.org/specification/ORCv1/)
  - [v2 specification](https://orc.apache.org/specification/ORCv2/) exists, but it seems there is [no progress since 2018](https://issues.apache.org/jira/browse/ORC-348).
- [protobuf definition](https://github.com/apache/orc-format/blob/v1.0.0/src/main/proto/orc/proto/orc_proto.proto)

# Links
- [An Empirical Evaluation of Columnar Storage Formats](https://www.vldb.org/pvldb/vol17/p148-zeng.pdf)
- [Exploiting Cloud Object Storage for High-Performance Analytics](https://www.vldb.org/pvldb/vol16/p2769-durner.pdf)
- [Amazon's Exabyte-Scale Migration from Apache Spark to Ray on Amazon EC2](https://aws.amazon.com/jp/blogs/opensource/amazons-exabyte-scale-migration-from-apache-spark-to-ray-on-amazon-ec2/)
