---
layout: memo
title: DuckDB Code Reading
---

Based on DuckDB [v0.8.1](https://github.com/duckdb/duckdb/tree/v0.8.1)

# Extension

## Install
- Extensions are downloaded from [extensions.duckdb.org](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/src/main/extension/extension_install.cpp#L186C36-L186C58) by default.
- Extensions are installed on `${DBConfigOptions.extension_directory or $HOME}.duckdb/extensions/${version_dir}/${platform}` ([code](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/src/main/extension/extension_install.cpp#L38))

## Load
- Load procedure
  1. call `{extension_name}_version` to check extension version and compare with running DuckDB version ([code](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/src/main/extension/extension_load.cpp#L169-L194))
  2. call `{extension_name}_init` ([code](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/src/main/extension/extension_load.cpp#L246-L256))

## Extension implementation
- Implement `{extension_name}_init` and `{extension_name}_version`
  - [example: parquet extension](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/extension/parquet/parquet-extension.cpp#L809-L819)
- Implement [Extension](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/src/include/duckdb/main/extension.hpp#L18-L24) class for initializationo

### Extension types
- Use `ExtensionUtil::RegisterFunction` to register function
