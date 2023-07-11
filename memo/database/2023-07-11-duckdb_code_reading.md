---
layout: memo
title: DuckDB Code Reading
---

Based on DuckDB [v0.8.1](https://github.com/duckdb/duckdb/tree/v0.8.1)

# Extension

## Install

## Load
- Implement `Extension` class to create an extension
- Use `ExtensionUtil::RegisterFunction` to register function

### Parquet extension
- ParquetExtension::Load on parquet_extension.cpp