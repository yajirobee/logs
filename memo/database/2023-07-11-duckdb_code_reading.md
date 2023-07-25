---
layout: memo
title: DuckDB Code Reading
---

Based on DuckDB [v0.8.1](https://github.com/duckdb/duckdb/tree/v0.8.1)

# Extension

## Install
- Extensions are downloaded from [extensions.duckdb.org](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/src/main/extension/extension_install.cpp#L186C36-L186C58) by default.
- Extensions are installed on `${DBConfigOptions.extension_directory or $HOME}.duckdb/extensions/${version_dir}/${platform}:`
  - [source](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/src/main/extension/extension_install.cpp#L38)

## Load
- Implement `Extension` class to create an extension
- Use `ExtensionUtil::RegisterFunction` to register function

### Parquet extension
- ParquetExtension::Load on parquet_extension.cpp
