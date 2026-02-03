---
layout: memo
title: Databricks note
---

# Compute
- Available access modes vary by whether Unity Catalog is enabled or not
  - With Unity Catalog enabled, [standard](https://docs.databricks.com/aws/en/compute/standard-overview) and [dedicated](https://docs.databricks.com/aws/en/compute/dedicated-overview) modes are recommended options.
    - With standard access mode, libraries and init scripts must be added to the [allowlist](https://docs.databricks.com/aws/en/data-governance/unity-catalog/manage-privileges/allowlist) to use them
      - allowlist cannot be disabled
    - [Lakeguard](https://docs.databricks.com/aws/en/compute/lakeguard)
  - The legacy access mode [no isolation shared](https://docs.databricks.com/aws/en/admin/account-settings/no-isolation-shared#what-are-no-isolation-shared-clusters) is also available
    - Unity Catalog is disabled on the compute

# Unity Catalog
- Unity Catalog is account-level resource
  - [Only one Unity Catalog can be created per region](https://docs.databricks.com/aws/en/data-governance/unity-catalog/best-practices#metastores)

## Links
- [What is Unity Catalog?](https://docs.databricks.com/aws/en/data-governance/unity-catalog/)
