---
layout: memo
title: Terraform
---

# Perpetual diffs issue of RDS DB parameter group
AWS provider has [a known issue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group#problematic-plan-changes) that causes unexpected plan changes after running `terraform apply` (i.e. perpetual diffs).

Some solutions are suggested by the document, but there is another workaround.
Ignore changes of "parameter" block as follows:
```terraform
lifecycle {
  ignore_changes = [parameter]
}
```
and comment out it when there are DB parameter changes.
Unfortunately, there is no way to ignore only "apply_method" changes.
There is [an open ticket](https://github.com/hashicorp/terraform/issues/5666) for that,
but no update in 9 years (as of 2025).
