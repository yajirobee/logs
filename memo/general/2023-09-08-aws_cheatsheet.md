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
