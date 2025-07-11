---
layout: blog
title: "Study Apache Iceberg ecosystems in AWS"
tags: Database AWS
---

[WIP] Study note about Apache Iceberg ecosystems in AWS.
<!--end_excerpt-->

# S3 Tables
S3 Tables supports IAM-based and resource-based access control and automatic maintenance operations for Iceberg tables stored in buckets.

- S3 Tables is available in S3 table buckets.
- Unreferenced file removal is [enabled for all tables by default](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-table-buckets-maintenance.html)
  - It can be configured per table
- Compaction and snapshot is [enabled for all tables by default](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-maintenance.html)
  - It can be configured per table
- [Resource mapping between AWS Glue](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-integrating-aws.html) (left is S3 Table resource, right is Glue resource)
  - Table bucket = Catalog
  - Namespace = Database
  - Table = Table
- [Client configuration to use Glue Iceberg endpoint](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-integrating-glue-endpoint.html#setup-client-glue-irc)
  - Sigv4 properties : Sigv4 must be enabled, the signing name is glue
  - Warehouse location : `<accountid>:s3tablescatalog/<table-bucket-name>`
  - Endpoint URI : Refer to the AWS Glue service endpoints reference guide for the region-specific endpoint

## [Quotas](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-regions-quotas.html#s3-tables-quotas)
- Table buckets per region in an AWS account = [10](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-buckets-create.html)
- Namespaces in a table bucket = 10,000
- Tables in a table bucket = [10,000](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-create.html)

## [Limitations](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-restrictions.html)
  - Presigned URLs to access objects associated with a table are not supported.
  - Tags are not supported for table buckets and tables. Therefore, support for attribute-based access control and tag-based allocation is unavailable.

# AWS Glue


# Links
- [S3 Tables and table bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html)
  - [Accessing S3 tables using Glue Iceberg REST endpoint](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-integrating-glue-endpoint.html)
- [AWS Glue](https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html)
  - [Data discovery and cataloging in Glue](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html)
  - [Connecting to the Data Catalog using Glue Iceberg REST endpoint](https://docs.aws.amazon.com/glue/latest/dg/connect-glu-iceberg-rest.html)
  - [Access Apache Iceberg tables in Amazon S3 from Databricks using AWS Glue Iceberg REST Catalog in Amazon SageMaker Lakehouse](https://aws.amazon.com/blogs/big-data/access-amazon-s3-iceberg-tables-from-databricks-using-aws-glue-iceberg-rest-catalog-in-amazon-sagemaker-lakehouse/#:~:text=This%20shows%20that%20you%20can,Formation%20managing%20the%20data%20access.)
- [AWS Lake Formation](https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html)
- [Delta sharing](https://github.com/delta-io/delta-sharing?tab=readme-ov-file)
