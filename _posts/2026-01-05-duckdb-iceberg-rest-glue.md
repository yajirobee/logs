---
layout: blog
title: Access Iceberg tables managed in AWS Glue Iceberg REST catalog and S3 Tables
tags: Database AWS
---

Memo to access Iceberg tables managed in AWS Glue Iceberg REST catalog and S3 Tables.
<!--end_excerpt-->

I used DuckDB [1.4.3](https://github.com/duckdb/duckdb/releases/tag/v1.4.3).

# Setup
1. Install and load extensions
```
INSTALL aws;
INSTALL httpfs;
INSTALL iceberg;
LOAD iceberg;
```
2. Create a secret that is used to access the Iceberg REST catalog and tables
```
CREATE SECRET (
    TYPE s3,
    PROVIDER credential_chain,
    CHAIN sts,
    ASSUME_ROLE_ARN 'arn:aws:iam::account_id:role/role',
    REGION 'us-east-1'
);
```
3. Connect to the catalog
```
ATTACH 'account_id' AS glue_catalog (
    TYPE iceberg,
    ENDPOINT 'glue.REGION.amazonaws.com/iceberg',
    AUTHORIZATION_TYPE 'sigv4'
);

-- for federated catalogs of s3 table buckets
ATTACH 'account_id:s3tablescatalog/table_bucket_name' AS glue_catalog (
    TYPE iceberg,
    ENDPOINT_TYPE 'glue'
);
```

Note: To create tables in Glue Iceberg REST catalog, you need to specify `ENDPOINT_TYPE` instead of `ENDPOINT` or
disable [support_stage_create](https://github.com/duckdb/duckdb-iceberg/blob/92837bdaa25ca0fc78300c4ced004228044991f7/src/storage/irc_catalog.cpp#L456-L459) explicitly.
`support_stage_create` is not supported in Glue Iceberg REST catalog and it is enabled by default when `ENDPOINT` is specified.

## Check
- Confirm that the catalog is attached
```
D show databases;
| database_name |
|---------------|
| glue_catalog  |
| memory        |
```

The document suggests to use `show all tables` to see attached tables, but it didn't return attached tables.

# Query
To access attached Iceberg tables, you need to specify a table by `catalog.namespace.table` format.
```sql
select count(*) from glue_catalog.tpch.nation;
```

- create schema (database in REST catalog) and table
```sql
create schema glue_catalog.test_db;
create table glue_catalog.test_db.test_tbl as select n from generate_series(1, 100) s(n);
```

```
D select count(*) from glue_catalog.test_db.test_tbl;
+--------------+
| count_star() |
+--------------+
| 100          |
+--------------+
```

# Links
- [Iceberg Extension](https://duckdb.org/docs/stable/core_extensions/iceberg/overview)
  - [Reading tables through AWS Glue catalog](https://duckdb.org/docs/stable/core_extensions/iceberg/amazon_sagemaker_lakehouse)
- [AWS Extension](https://duckdb.org/docs/stable/core_extensions/aws)
- [Secrets Manager](https://duckdb.org/docs/stable/configuration/secrets_manager)
