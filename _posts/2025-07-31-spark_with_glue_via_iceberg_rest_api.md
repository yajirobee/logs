---
layout: blog
title: Use Spark with AWS Glue Iceberg REST API and S3 Tables
tags: Database AWS
---

A quick experiment to use Spark for Iceberg tables stored on S3 table buckets and
managed by Glue Data Catalog via Iceberg REST API.

<!--end_excerpt-->
[S3 Tables](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html) provides built-in
support for [Apache Iceberg](https://iceberg.apache.org/) format. It also provides [integration](https://docs.aws.amazon.com/lake-formation/latest/dg/create-s3-tables-catalog.html)
with Glue and Lake Formation. When the integration is enabled, tables stored on table buckets are
registered to Glue Data Catalog and available through
[Iceberg REST API](https://docs.aws.amazon.com/glue/latest/dg/iceberg-rest-apis.html).

This post explains how to use Iceberg tables of S3 Tables by Apache Spark via Glue Iceberg REST API.

# Environment
- Run Spark locally on a container by using [apache/spark](https://hub.docker.com/r/apache/spark/) image

# Run interactive pyspark session on a local container
```sh
export AWS_REGION=${your_region}
# retrieve and export credentials
eval $(aws configure export-credentials --format env)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# packages required to use iceberg and S3
ICEBERG_VERSION="1.9.2"
SPARK_SCALA_VERSION="3.5_2.12"
AWS_SDK_VERSION="2.32.10"
HADOOP_AWS_VERSION="3.3.6"
# need s3, sts, glue, dynamodb, kms packages from aws sdk
SPARK_PACKAGES_CONFIG="org.apache.iceberg:iceberg-spark-runtime-${SPARK_SCALA_VERSION}:${ICEBERG_VERSION},software.amazon.awssdk:s3:${AWS_SDK_VERSION},software.amazon.awssdk:sts:${AWS_SDK_VERSION},software.amazon.awssdk:glue:${AWS_SDK_VERSION},software.amazon.awssdk:dynamodb:${AWS_SDK_VERSION},software.amazon.awssdk:kms:${AWS_SDK_VERSION},org.apache.hadoop:hadoop-aws:${HADOOP_AWS_VERSION}"

GLUE_CATALOG_ID="${AWS_ACCOUNT_ID}"
# If you used S3 Table and Glue/Lake Formation integration, a catalog is created per table bucket
# GLUE_CATALOG_ID="${AWS_ACCOUNT_ID}:s3tablescatalog/${BUCKET_NAME}""

podman run --rm -it \
  --name spark-iceberg-job \
  -v ./:/opt/spark/work-dir \
  -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  -e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
  -e AWS_REGION="${AWS_REGION}" \
  spark:3.5.6-java17-python3 \
  /opt/spark/bin/pyspark \
  --conf "spark.jars.packages=${SPARK_PACKAGES_CONFIG}" \
  --conf "spark.jars.ivy=/opt/spark/work-dir/.ivy" \
  --conf "spark.sql.catalog.glue_rest_catalog=org.apache.iceberg.spark.SparkCatalog" \
  --conf "spark.sql.catalog.glue_rest_catalog.type=rest" \
  --conf "spark.sql.catalog.glue_rest_catalog.warehouse=${GLUE_CATALOG_ID}" \
  --conf "spark.sql.catalog.glue_rest_catalog.uri=https://glue.${AWS_REGION}.amazonaws.com/iceberg" \
  --conf "spark.sql.catalog.glue_rest_catalog.rest.auth.type=sigv4" \
  --conf "spark.sql.catalog.glue_rest_catalog.rest.signing-name=glue" \
  --conf "spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions" \
  --conf "spark.sql.defaultCatalog=glue_rest_catalog"
```

## SQL examples
- list databases
```python
spark.sql("SHOW databases").show()
```

- list tables
```python
spark.sql("SHOW tables in test_db").show()
```

- create database
```python
spark.sql("CREATE DATABASE test_db")
```

- create table
```python
create_table_sql = f"""
CREATE TABLE IF NOT EXISTS test_db.test_tbl (id LONG)
USING iceberg
LOCATION 's3://{BUCKET_NAME}/{DATABASE_NAME}/{TABLE_NAME}'
TBLPROPERTIES ('write.format.default'='parquet')
"""
spark.sql(create_table_sql)
```

- read table
```python
spark.table('test_db.test_tbl').show()
```

# Links
- Spark doc
  - [Submitting applications](https://spark.apache.org/docs/3.5.6/submitting-applications.html)
  - [Configurations](https://spark.apache.org/docs/3.5.6/configuration.html)
- Iceberg doc
    - [Spark getting started](https://iceberg.apache.org/docs/latest/spark-getting-started/)
    - [Spark configuration](https://iceberg.apache.org/docs/latest/spark-configuration/)
  - Open API
    - [Github](https://github.com/apache/iceberg/blob/main/open-api/rest-catalog-open-api.yaml)
    - [Swagger](https://editor-next.swagger.io/?url=https://raw.githubusercontent.com/apache/iceberg/main/open-api/rest-catalog-open-api.yaml)
  - Github
    - [AWS properties](https://github.com/apache/iceberg/blob/main/aws/src/main/java/org/apache/iceberg/aws/AwsProperties.java)
- AWS doc
  - [Client configuration to use Glue Iceberg endpoint with S3 Tables](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-integrating-glue-endpoint.html#setup-client-glue-irc)
  - [Connect Glue Iceberg REST endpoint](https://docs.aws.amazon.com/glue/latest/dg/connect-glu-iceberg-rest.html)
  - [Using Iceberg REST Catalog (IRC) with Spark Iceberg](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-iceberg-use-spark-cluster.html#emr-iceberg-rest-catalog-config)
