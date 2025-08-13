---
layout: blog
title: "Study Apache Iceberg ecosystems in AWS"
tags: Database AWS
---

Study note about Apache Iceberg ecosystems in AWS.
<!--end_excerpt-->

# S3 Tables
S3 Tables supports IAM-based and resource-based access control and automatic maintenance operations for Iceberg tables stored in buckets. S3 Tables is available in S3 table buckets. It was [released on 2024/12/03](https://aws.amazon.com/blogs/aws/new-amazon-s3-tables-storage-optimized-for-analytics-workloads/).

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
- [IAM actions / resources / condition keys for S3 Tables](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazons3tables.html)

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

## Access control
- [A resource-based policy can be attached to a catalog](https://docs.aws.amazon.com/glue/latest/dg/security_iam_service-with-iam.html#security_iam_service-with-iam-resource-based-policies)
  - [ARNs of data catalog resources](https://docs.aws.amazon.com/glue/latest/dg/glue-specifying-resource-arns.html#data-catalog-resource-arns)
    - Federated catalogs are also catalog resources
- Cross-account permissions of Glue and Lake Formation [can be used at the same time](https://docs.aws.amazon.com/lake-formation/latest/dg/hybrid-cross-account.html)

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
# AWS Lake Formation (LF)
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
  - LF-Tag can be assigned for databases and tables, not for catalogs

- [Metadata access control](https://docs.aws.amazon.com/lake-formation/latest/dg/access-control-metadata.html)
- [Lake Formation personas and IAM permissions reference](https://docs.aws.amazon.com/lake-formation/latest/dg/permissions-reference.html)
- [Lake Formation permissions reference](https://docs.aws.amazon.com/lake-formation/latest/dg/lf-permissions-reference.html)

### Underlying data access permissions
The following permissions are required to enable principals to read and write underlying data

- Register the Amazon S3 locations that contain the data with Lake Formation.
- Principals who create Data Catalog tables that point to underlying data locations must have data location permissions.
- Principals who read and write underlying data must have Lake Formation data access permissions on the Data Catalog tables that point to the underlying data locations.
- Principals who read and write underlying data must have the lakeformation:GetDataAccess IAM permission when the underlying data location is registered with Lake Formation.

> The Lake Formation permissions model doesn't prevent access to Amazon S3 locations through the Amazon S3 API or console if you have access to them through IAM or Amazon S3 policies. You can attach IAM policies to principals to block this access.

(from [Underlying data access control](https://docs.aws.amazon.com/lake-formation/latest/dg/access-control-underlying-data.html))

### [Cross account data sharing](https://docs.aws.amazon.com/lake-formation/latest/dg/cross-account-permissions.html)
- Query and join tables across multiple accounts is available with cross account data sharing
- AWS Resource Access Manger (RAM) is used to share LF resources
- If the grantee (provider) account is in the same [organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) as the grantor (consumer) account, shared access is available immediately
  - Otherwise, RAM sends an invitation to the grantee account to accept or reject the resource grant
- [Setup required in each consumer account](https://docs.aws.amazon.com/lake-formation/latest/dg/cross-account-prereqs.html)
  - at least one user in the consumer account must be a [data lake administrator](https://docs.aws.amazon.com/lake-formation/latest/dg/initial-lf-config.html#create-data-lake-admin) to view shared resources
  - The data lake administrator can grant Lake Formation permissions on the shared resources to other principals in the account
- The consumer account principals cannot assign new LF-Tags for shared resources
  - For fine grained database or table level access control in the consumer account, only named resource based method is available
- [Permissions required to access underlying data of shared table](https://docs.aws.amazon.com/lake-formation/latest/dg/cross-account-read-data.html)

[Example steps](https://docs.aws.amazon.com/lake-formation/latest/dg/cross-account-TBAC.html) for cross account data sharing with LF-TBAC
- [grantor]: set required IAM permissions for Glue and RAM resources
  - [Prerequisites](https://docs.aws.amazon.com/lake-formation/latest/dg/cross-account-prereqs.html)
- [grantee]: create a data lake administrator
- [grantor]: assign LF-Tag to databases and tables
  - [Assigning LF-tags to Data Catalog resources](https://docs.aws.amazon.com/lake-formation/latest/dg/TBAC-assigning-tags.html)
- [grantor]: grant data permission to external accounts using LF-Tag expressions
- [grantor]: (If credential vending isn't used by consumer) grant permissions to access underlying data, e.g. S3 to external accounts or principals by resource-based permissions
- [grantee]: receive the resource share in RAM as a data lake administrator
- [grantee]: the data lake administrator grants LF-Tag key-value permissions to other IAM principals
  - [Granting permissions on shared databases and tables](https://docs.aws.amazon.com/lake-formation/latest/dg/regranting-shared-resources.html)
- [grantee]: grant permissions required to access underlying data of shared tables for IAM principals that read data
- [grantee]: (If credential vending isn't used) grant permissions to access underlying data for IAM principals that read data

## Permissions enforcement
- [Permissions management workflow](https://docs.aws.amazon.com/lake-formation/latest/dg/how-it-works.html#lf-workflow)
  - If the user is authorized, Lake Formation provides temporary access to data
  - Creation of tables at specific S3 location can be blocked by data location permissions

### [Storage access management](https://docs.aws.amazon.com/lake-formation/latest/dg/storage-permissions.html)
- Column level, row level and cell level filtering are enforced by the integrated service
  - Integrated services are trusted to properly enforce Lake Formation permissions (distributed-enforcement)

### [Credential vending](https://docs.aws.amazon.com/lake-formation/latest/dg/using-cred-vending.html)
- Lake Formation can vend scoped-down temporary credentials in the form of AWS STS tokens to registered Amazon S3 locations based on the effective permissions
- Credential vending APIs
  - `GetTemporaryGlueTableCredentials`
  - `GetTemporaryGluePartitionCredentials`
  - APIs are disabled by default.
    - [Third party query engines must be registered](https://docs.aws.amazon.com/lake-formation/latest/dg/permitting-third-party-call.html) to use them or [full access must be enabled](https://docs.aws.amazon.com/lake-formation/latest/dg/full-table-credential-vending.html)
      - Registered IAM session tag must be set when third party query engines call assume role for the role that is used to call credential vending APIs.
- Credential vending only works with queries that run through the AWS Glue ETL library
- Lake Formation credential vending API operations enable a distributed-enforcement with explicit deny on failure (fail-close) model
  - [Roles and responsibilities](https://docs.aws.amazon.com/lake-formation/latest/dg/roles-and-responsibilities.html)
  - [Snowflake supports use of vended credentials](https://docs.snowflake.com/en/user-guide/tables-iceberg-configure-catalog-integration-vended-credentials)

## [Quotas](https://docs.aws.amazon.com/general/latest/gr/lake-formation.html#limits_lake-formation)
- Number of registered paths per region in an AWS account = 10,000

## Links
- [AWS Lake Formation](https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html)
- [Bringing your data into Glue Data Catalog](https://docs.aws.amazon.com/lake-formation/latest/dg/bring-your-data-overview.html)
