---
layout: blog
title: "Study Apache Iceberg ecosystems in AWS"
tags: Database AWS
---

[WIP] Study note about Apache Iceberg ecosystems in AWS.
<!--end_excerpt-->

# S3 Tables
S3 Tables supports IAM-based and resource-based access control and automatic maintenance operations for Iceberg tables stored in buckets. S3 Tables is available in S3 table buckets.

## Table maintenance
[Unreferenced file removal](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-table-buckets-maintenance.html) and
[Compaction and snapshot](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-maintenance.html)
are enabled by default. They are configurable per table.

## [Integration with Glue and Lake Formation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-integrating-aws.html)
S3 table buckets can be integrated with Glue and Lake Formation. When the integration is enabled,
a Glue catalog is created per table bucket and Iceberg tables are managed on that catalog.

The integration is enabled by the following steps.
1. registering buckets to Lake Formation as data location
2. creating a federated catalog on Glue

- Resource mapping between AWS Glue (left is S3 Table resource, right is Glue resource)
  - Table bucket = Catalog
  - Namespace = Database
  - Table = Table
- [Client configuration to use Glue Iceberg endpoint](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-integrating-glue-endpoint.html#setup-client-glue-irc)
  - Warehouse location : `<accountid>:s3tablescatalog/<table-bucket-name>`

## [Quotas](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-regions-quotas.html#s3-tables-quotas)
- Table buckets per region in an AWS account = [10](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-buckets-create.html)
- Namespaces in a table bucket = 10,000
- Tables in a table bucket = [10,000](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-create.html)

## [Limitations](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-restrictions.html)
  - Presigned URLs to access objects associated with a table are not supported.
  - Tags are not supported for table buckets and tables. Therefore, support for attribute-based access control and tag-based allocation is unavailable.

## Links
- [S3 Tables and table bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html)
  - [Accessing S3 tables using Glue Iceberg REST endpoint](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-integrating-glue-endpoint.html)

---
# AWS Glue
- [Creating Iceberg tables](https://docs.aws.amazon.com/glue/latest/dg/populate-otf.html#creating-iceberg-tables)
  - By default, Iceberg v2 tables are created
  - > Data Catalog doesn’t support creating partitions and adding Iceberg table properties.
- [Optimizing Iceberg tables](https://docs.aws.amazon.com/glue/latest/dg/table-optimizers.html)
  - The same table optimizers as S3 Tables are available
  - Number of distinct values (NDVs) of columns is also [supported](https://docs.aws.amazon.com/glue/latest/dg/iceberg-column-statistics.html)

## Data Catalog
- An AWS account has a default Data Catalog per region
  - Catalog ID = account ID
  - Only the default catalog is displayed on Glue UI
    - Non-default catalogs are available on API
      - [GetCatalogs](https://docs.aws.amazon.com/glue/latest/webapi/API_GetCatalogs.html)
    - Also available on Lake Formation UI
- Iceberg REST APIs have a free-form prefix. It can be used to logically segments catalogs.
  - [Prefix and catalog path parameters](https://docs.aws.amazon.com/glue/latest/dg/connect-glu-iceberg-rest.html#prefix-catalog-path-parameters)
  - For S3 Tables, catalog ID is `<accountid>:s3tablescatalog/<table-bucket-name>`
    - [S3 Table integration](https://docs.aws.amazon.com/lake-formation/latest/dg/enable-s3-tables-catalog-integration.html) must be enabled on Lake Formation
  - For Iceberg tables in regular S3 buckets, prefix / catalog ID is unavailable.
    - All tables are stored in the default Data Catalog (Catalog ID = AWS account ID) (reference: [Populating catalog](https://docs.aws.amazon.com/lake-formation/latest/dg/populating-catalog.html))

## [Quotas](https://docs.aws.amazon.com/general/latest/gr/glue.html#limits_glue)
- Max databases per region in an AWS account = 10,000
- Max tables per region in an AWS account = 1,000,000
- Max tables per database = 200,000

## Links
- [AWS Glue](https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html)
  - [Data discovery and cataloging in Glue](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html)
  - [Glue Iceberg REST API spec](https://docs.aws.amazon.com/glue/latest/dg/iceberg-rest-apis.html)
  - [Access Iceberg tables in S3 from Databricks using AWS Glue Iceberg REST Catalog](https://aws.amazon.com/blogs/big-data/access-amazon-s3-iceberg-tables-from-databricks-using-aws-glue-iceberg-rest-catalog-in-amazon-sagemaker-lakehouse/)
  - [Connect Snowflake to S3 tables using Iceberg REST endpoint](https://aws.amazon.com/blogs/storage/connect-snowflake-to-s3-tables-using-the-sagemaker-lakehouse-iceberg-rest-endpoint/)
- [Iceberg REST Catalog API](https://editor-next.swagger.io/?url=https://raw.githubusercontent.com/apache/iceberg/main/open-api/rest-catalog-open-api.yaml)

---
# AWS Lake Formation
Lake Formation provides RDBMS permissions model to grant or revoke access to Data Catalog resources.

## [Permissions model](https://docs.aws.amazon.com/lake-formation/latest/dg/lf-permissions-overview.html)
Lake Formation manages two types of permissions.
- Metadata access (Data Catalog permissions)
  - Permissions on Data Catalog resources
- Underlying data access
  - Permissions to read and write data to S3 locations pointed by Data Catalog resources

Lake Formation uses a combination of Lake Formation permissions and IAM permissions.
A principal must pass both Lake Formation and IAM permissions checks.

### [Metadata permissions](https://docs.aws.amazon.com/lake-formation/latest/dg/metadata-permissions.html)
  - By default, all databases and tables have `IAMAllowedPrincipal` group
    - If this permissions exists on a database or table, all principals will be granted access to the database or table
    - `IAMAllowedPrincipal` must be removed for granular access control
    - `IAMAllowedPrincipal` is set to new databases and tables by default. The default setting can be modified.
  - LF-Tag based access control (LF-TBAC) is the best way to scale permissions across huge number of resources

- [Metadata access control](https://docs.aws.amazon.com/lake-formation/latest/dg/access-control-metadata.html)

## Permissions enforcement
- [Permissions management workflow](https://docs.aws.amazon.com/lake-formation/latest/dg/how-it-works.html#lf-workflow)
  - If the user is authorized, Lake Formation provides temporary access to data
  - [Credential vending](https://docs.aws.amazon.com/lake-formation/latest/dg/using-cred-vending.html)
  - Creation of tables at specific S3 location can be blocked by data location permissions

### [Storage access management](https://docs.aws.amazon.com/lake-formation/latest/dg/storage-permissions.html)
  - Column level, row level and cell level filtering are enforced by the integrated service

> The Lake Formation permissions model doesn't prevent access to Amazon S3 locations through the Amazon S3 API or console if you have access to them through IAM or Amazon S3 policies. You can attach IAM policies to principals to block this access.

[Underlying data access control](https://docs.aws.amazon.com/lake-formation/latest/dg/access-control-underlying-data.html)

## [Integrating with Lake Formation](https://docs.aws.amazon.com/lake-formation/latest/dg/Integrating-with-LakeFormation.html)
- [Roles and responsibilities](https://docs.aws.amazon.com/lake-formation/latest/dg/roles-and-responsibilities.html)

## [Quotas](https://docs.aws.amazon.com/general/latest/gr/lake-formation.html#limits_lake-formation)
- Number of registered paths per region in an AWS account = 10,000

## Links
- [AWS Lake Formation](https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html)
- [Bringing your data into Glue Data Catalog](https://docs.aws.amazon.com/lake-formation/latest/dg/bring-your-data-overview.html)
