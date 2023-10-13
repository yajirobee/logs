---
layout: memo
title: AWS cheatsheet
---

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

## Data transfer bandwidth between S3
> Traffic between Amazon EC2 and Amazon S3 can leverage up to 100 Gbps of bandwidth to VPC endpoints and public IPs in the same Region.

From [What's the maximum transfer speed between Amazon EC2 and Amazon S3?](https://repost.aws/knowledge-center/s3-maximum-transfer-speed-ec2)

### Links
- [How can I improve the transfer speeds for copying data between my S3 bucket and EC2 instance?](https://repost.aws/knowledge-center/s3-transfer-data-bucket-instance)
- [Network performance of EC2 instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/general-purpose-instances.html#general-purpose-network-performance)

# S3
## Range get
> Using the Range HTTP header in a GET Object request, you can fetch a byte-range from an object, transferring only the specified portion

From [Use Byte-Range Fetches](https://docs.aws.amazon.com/whitepapers/latest/s3-optimizing-performance-best-practices/use-byte-range-fetches.html)

## Concurrency on CLI
Change [max\_concurrent\_requests](https://awscli.amazonaws.com/v2/documentation/api/latest/topic/s3-config.html#configuration-values).
```sh
aws configure set default.s3.max_concurrent_requests 20
```
