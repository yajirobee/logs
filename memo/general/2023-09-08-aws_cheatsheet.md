---
layout: memo
title: AWS cheatsheet
---

# IAM

- [Signature Version 4](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_sigv.html)

## [Policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
- When an IAM entity (user or role) requests access to a resource within the same account, AWS evaluates all the permissions granted by the identity-based and resource-based policies.
  - An explicit deny in either of these policies overrides the allow.
    - Explicit deny: policy with `DENY` statement
    - Inplicit deny: there is no applicable `DENY` and `ALLOW` statements

## [Permissions boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)
- Within the same account, resource-based policies that grant permissions to an IAM user ARN are not limited by an implicit deny in an identity-based policy or permissions boundary.
- Resource-based policies that grant permissions to an IAM role ARN are limited by an implicit deny in a permissions boundary or session policy.

## [Cross account resource access](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies-cross-account-resource-access.html)
- To share the resource directly, the resource that you want to share must support resource-based policies.
  - Unlike an identity-based policy for a role, a resource-based policy specifies who (which principal) can access that resource.
  - In cross account access, a principal needs an Allow in the identity policy and the resource-based policy.
- Use a role as a proxy when you want to access resources in another account that do not support resource-based policies.

[IAM Access Analyzer](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html#what-is-access-analyzer-resource-identification) helps to identify the resources shared with an external entity.

## Links
- [AWS services that work with IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html)

# EC2

## [Instance Metadata]((https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html))

### Get credentials of instance profile IAM role
```sh
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${role-name}
```
- [Retrieve security credentials from instance metadata](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html#instance-metadata-security-credentials)

### Get region
```sh
curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region'
```
- [Instance identity documents](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-identity-documents.html)

### Get user data
```sh
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
sudo cat /var/lib/cloud/instances/$INSTANCE_ID/user-data.txt
```

or

```sh
curl http://169.254.169.254/2021-03-23/user-data
```

## Data transfer bandwidth between S3
> Traffic between Amazon EC2 and Amazon S3 can leverage up to 100 Gbps of bandwidth to VPC endpoints and public IPs in the same Region.

From [What's the maximum transfer speed between Amazon EC2 and Amazon S3?](https://repost.aws/knowledge-center/s3-maximum-transfer-speed-ec2)

### Links
- [How can I improve the transfer speeds for copying data between my S3 bucket and EC2 instance?](https://repost.aws/knowledge-center/s3-transfer-data-bucket-instance)
- [Network performance of EC2 instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/general-purpose-instances.html#general-purpose-network-performance)

# EBS
## Provisioned IOPS SSD volumes
Provisioned IOPS is calculated with IO size = 16KiB ([reference](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/provisioned-iops.html)).

# S3
## Range get
> Using the Range HTTP header in a GET Object request, you can fetch a byte-range from an object, transferring only the specified portion

From [Use Byte-Range Fetches](https://docs.aws.amazon.com/whitepapers/latest/s3-optimizing-performance-best-practices/use-byte-range-fetches.html)

## Concurrency on CLI
Change [max\_concurrent\_requests](https://awscli.amazonaws.com/v2/documentation/api/latest/topic/s3-config.html#configuration-values).
```sh
aws configure set default.s3.max_concurrent_requests 20
```

## Mounting S3 bucket as a local file system
- [Mountpoint for Amazon S3](https://github.com/awslabs/mountpoint-s3)
- [The inside story on Mountpoint for Amazon S3, a high-performance open source file client](https://aws.amazon.com/blogs/storage/the-inside-story-on-mountpoint-for-amazon-s3-a-high-performance-open-source-file-client/)

# RDS
## Aurora
### DB cluster parameter group vs DB parameter group
> The values in the DB parameter group can override default values from the cluster parameter group.

from: [Amazon Aurora DB cluster and DB instance parameters](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_WorkingWithDBClusterParamGroups.html#Aurora.Managing.ParameterGroups)

## Enhanced monitoring
- [OS metrics in Enhanced Monitoring](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring-Available-OS-Metrics.html)

## Performance insights
- [Tuning with wait events for RDS for PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Tuning.html)

# SDK
## Retry behavior
- [General retry behavior of SDKs](https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html)
- [Retry behavior of SDK for Java v2](https://docs.aws.amazon.com/sdk-for-java/latest/developer-guide/using.html#using-retries)

# CLI
## [Export credentials](https://docs.aws.amazon.com/cli/latest/reference/configure/export-credentials.html)
retrieve AWS credentials using credential resolution process, e.g. assume role
```sh
$ aws configure export-credentials --profile engineering
{
  "Version": 1,
  "AccessKeyId": ...,
  "SecretAccessKey": ...,
  "SessionToken": ...,
  "Expiration": ...
}
```

# Links
- [AWS Latency Monitoring](https://www.cloudping.co/grid)
