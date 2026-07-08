---
layout: memo
title: Snowflake note
---

# Concepts
## Data hierarchy
- [Data asset hierarchy](https://docs.snowflake.com/en/sql-reference/ddl-database)
  - Database -> Schema -> Tables / Views / ...

## Virtual warehouses
- [Virtual warehouse](https://docs.snowflake.com/en/user-guide/warehouses): a cluster of compute resources
  - often referred to simply as a “warehouse”,

# Access control
- [Overview of Access Control](https://docs.snowflake.com/en/user-guide/security-access-control-overview)

> In Snowflake, privileges assigned to roles or users allow access to securable objects. Roles can be assigned to users or other roles. Granting a role to another role creates a role hierarchy

- [Access control privileges](https://docs.snowflake.com/en/user-guide/security-access-control-privileges)

## Who can grant privileges
- Regular schema: Owner role
  - the owner role has all privileges on the object by default
  - Ownership can be transferred from one role to another.
- [Managed access schema](https://docs.snowflake.com/en/user-guide/security-access-control-configure#label-managed-access-schemas): Schema owner or a role with `MANAGE GRANT` privilege
  - Object owners lose the ability to make grant decisions

## Secondary roles
- [Secondary roles](https://docs.snowflake.com/en/user-guide/security-access-control-overview#label-access-control-role-enforcement) can be activated in a user session
- authorization to execute `CREATE <object>` statements to create objects is provided by the primary role

[use secondary roles](https://docs.snowflake.com/en/sql-reference/sql/use-secondary-roles)
```sql
-- use all roles that have been granted to the user
use secondary roles all;
```

## The ACCOUNTADMIN role
[ACCOUNTADMIN](https://docs.snowflake.com/en/user-guide/security-access-control-considerations#using-the-accountadmin-role) role is the most powerful role in the system.

- ACCOUNTADMIN is not a superuser role
  - This role only allows viewing and managing objects in the account if this role, or a role lower in a role hierarchy, has sufficient privileges on the objects.

# Cheatsheet
## Check permissions
use [show grants](https://docs.snowflake.com/en/sql-reference/sql/show-grants) statement
```sql
-- Lists all the roles granted to the current user
show grants;
-- Lists all privileges and roles granted to the role
show grants to role public;
-- Lists all users and roles to which the role has been granted
show grants of role accountadmin;
```

## Check current role
use [current_role](https://docs.snowflake.com/en/sql-reference/functions/current_role) and [current_secondary_roles](https://docs.snowflake.com/en/sql-reference/functions/current_secondary_roles) functions
```sql
-- primary role
select current_role();
-- secondary roles
select current_secondary_roles();
```

# SQL commands
## [Flow operators](https://docs.snowflake.com/en/sql-reference/operators-flow)
- Pipe operator (`->>`) chains series of SQL statements
  - each subsequent statement can take the results of any previous statement as input
    - a previous SQL statement is referenced by a parameter with the dollar sign ($) and the pipe number
  - The output column names for SHOW and DESCRIBE commands are generated in lowercase.
    - If you consume a result set from a SHOW or DESCRIBE command with the pipe operator or the RESULT_SCAN function, use double-quoted identifiers for the column names in the query
