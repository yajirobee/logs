---
layout: memo
title: DuckDB Code Reading
---

Based on DuckDB [v0.10.0](https://github.com/duckdb/duckdb/tree/v0.10.0)

# Query Execution Flow
- Parser
- Planner
  - Entry point:`Planner::CreatePlan`
- Binder
  - Entry point: `Binder::Bind`
- Executor
  - Entry point: `Executor::ExecuteTask`

## Copy
`PipelineExecutor::Execute`
-> `PipelineExecutor::PushFinalize`
-> `PhysicalCopyToFile::Combine`
-> (custom) `CopyFunction::copy_to_combine`

# Join
- [Out of core hash join](https://github.com/duckdb/duckdb/pull/4189)

# Bulk load
- [Optimistic streaming write for data more than fits in memory in a single transaction](https://github.com/duckdb/duckdb/pull/4996)

> If the transaction is rolled back or aborted, the blocks that were pre-emptively written to disk are marked as unused and reclaimed by the system for use in subsequent writes. This might still cause the database file to grow temporarily, however, and may create gaps in the database file if there are multiple transactions writing at the same time with a subset of those transactions aborting. That space is not lost - however. It will be re-used by the system when new data is ingested.

# Internal data format
- [Execution format](https://duckdb.org/docs/internals/vector)
- [Lightweight Compression in DuckDB](https://duckdb.org/2022/10/28/lightweight-compression.html)

# Use Extension
Read extension [README.md](https://github.com/duckdb/duckdb/blob/v0.10.0/extension/README.md) first.

## Install
- Extensions are downloaded from "extensions.duckdb.org" by default.
  - Custom extension repository can be configured by `custom_extension_repository`.
  - [Distribute your extension](https://github.com/duckdb/extension-template#distributing-your-extension)
- Extensions are installed on `${DBConfigOptions.extension_directory or $HOME}.duckdb/extensions/${version_dir}/${platform}`

related code: `src/main/extension/extension_install.cpp`

## Load
- Load procedure
  1. call `{extension_name}_version` to check extension version and compare with running DuckDB version
  2. call `{extension_name}_init`

related code: `src/main/extension/extension_load.cpp`

# Extension implementation
- Implement `{extension_name}_init` and `{extension_name}_version`
- Implement `Extension` class and call `DuckDB::LoadExtension()`
  - Load is skipped on the second time.

related code: `src/include/duckdb/main/extension.hpp`

## Extension types
- Function types are defined on `src/include/duckdb/function`
- Use `ExtensionUtil::RegisterFunction` to register function
  - It creates an object of `CreateFunctionInfo`

### Table function
related code: `src/include/duckdb/function/table_function.hpp`

- Create an instance of `TableFunction`
- required fields are `function` and `bind`
  - `bind`: parse options and return `FunctionData` that stores parameters required to process scan
    - caller: `Binder::BindTableFunctionInternal`
    - fill `return_types` and `names`
  - `init_global`
    - caller: constructor of `TableScanGlobalSourceState` (<- `Executor::Initialize`)
    - override `MaxThreads` for multi threading
  - `init_local`
    - caller: constructor of `TableScanLocalSourceState` (<- `PipelineTask::ExecuteTask` <- `Executor::ExecuteTask`)
  - `function`: fill `DataChunk` and return until scan completes
    - caller: `PhysicalTableScan::GetData` (<- `PipelineTask::ExecuteTask` <- `Executor::ExecuteTask`)
      - finish if `chunk.size() == 0`

### Reading multiple files
[Overview](https://duckdb.org/docs/data/multiple_files/overview)

- `MultiFileReader::ParseOptions` : parse options for multi file reader
  - typically used in `TableFunction::bind`
- `MultiFileReader::FinalizeBind`
  - typically used in `TableFunction::init_global`
- `MultiFileReader::FinalizeChunk`
  - typically used in `TableFunction::function`

### Copy function
related code: `src/include/duckdb/function/copy_function.hpp`

## Tips
- Use unsigned extension from CLI
```sh
duckdb -unsigned
```

- [Extension build type](https://github.com/duckdb/duckdb/blob/6536a772329002b05decbfc0a9d3f606e0ec7f55/CMakeLists.txt#L817-L825)
> loadable extension binaries can be built two ways:
1. EXTENSION_STATIC_BUILD=1
   DuckDB is statically linked into each extension binary. This increases portability because in several situations
   DuckDB itself may have been loaded with RTLD_LOCAL. This is currently the main way we distribute the loadable
   extension binaries
2. EXTENSION_STATIC_BUILD=0
   The DuckDB symbols required by the loadable extensions are left unresolved. This will reduce the size of the binaries
   and works well when running the DuckDB cli directly. For windows this uses delay loading. For MacOS and linux the
   dynamic loader will look up the missing symbols when the extension is dlopen-ed.
