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
- Implement [Extension](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/src/include/duckdb/main/extension.hpp#L18-L24) class and call `DuckDB::LoadExtension()`
  - Load is skipped on the second time.

### Extension types
- Function types are defined on [src/include/duckdb/function](https://github.com/duckdb/duckdb/tree/v0.8.1/src/include/duckdb/function)
- Use `ExtensionUtil::RegisterFunction` to register function
  - It creates an object of `CreateFunctionInfo`

#### Table function
- Create an instance of [TableFunction](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/src/include/duckdb/function/table_function.hpp#L210)
- required fields are `function` and `bind`
  - `bind`: parse options and return `FunctionData` that stores parameters required to process scan
  - `function`: fill `DataChunk` and return until scan completes
    - `MultiFileReader::FinalizeChunk` can be used to fill a chunk.

## Tips
- Use unsigned extension from CLI
```sh
duckdb -unsigned
```

- [Extension build type](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/CMakeLists.txt#L817-L825)
>   # loadable extension binaries can be built two ways:
  # 1. EXTENSION_STATIC_BUILD=1
  #    DuckDB is statically linked into each extension binary. This increases portability because in several situations
  #    DuckDB itself may have been loaded with RTLD_LOCAL. This is currently the main way we distribute the loadable
  #    extension binaries
  # 2. EXTENSION_STATIC_BUILD=0
  #    The DuckDB symbols required by the loadable extensions are left unresolved. This will reduce the size of the binaries
  #    and works well when running the DuckDB cli directly. For windows this uses delay loading. For MacOS and linux the
  #    dynamic loader will look up the missing symbols when the extension is dlopen-ed.
