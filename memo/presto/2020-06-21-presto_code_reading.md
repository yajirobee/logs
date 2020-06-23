---
layout: memo
title: Presto Code Reading
---

Memo to read Presto code

Following memo is based on PrestoSQL 336 which is the latest version as of June 21st, 2020.

# Connector Implementation
- io.prestosql.spi.Plugin  
Entory point of a Plugin. Provides `io.prestosql.spi.connector.ConnectorFactory`  
configuration is provided here.  
  - reference: [SPI overview](https://prestosql.io/docs/current/develop/spi-overview.html)
- io.prestosql.spi.connector.Connector / ConnectorFactory  
`Collector` provides the instances of the following services:
  - io.prestosql.spi.connector.ConnectorMetadata
  - io.prestosql.spi.connector.ConnectorSplitManager
  - io.prestosql.spi.connector.ConnectorHandleResolver
  - io.prestosql.spi.connector.ConnectorRecordSetProvider
  - reference: [Connectors](https://prestosql.io/docs/current/develop/connectors.html)

# Service Provider interfaces (SPI)
Definition is from [Presto: The Definitive Guide](https://www.oreilly.com/library/view/presto-the-definitive/9781492044260/) (p48, Figure 4-5).

### Coodinator
- Metadata SPI
  - Used by Parser / Analyzer
  - check table, column, types
- Data Statistics SPI
  - Used by Planner / Optimizer
  - cost-based query optimization
- Data Location SPI
  - Scheduler
  - generate logical splits of the table contents

### Worker
- Data Stream SPI

# Query plan
## Terminology
- *Distributed query plan*: an extension of the simple query plan consisting of one or more stages
- *Stage*: runtime incarnation of a plan fragment. Having more than one stage results in the creation of a dependency tree of stages.
- *Tasks*: unit composes a stage. coordinator schedules tasks across the workers. It's the runtime incarnation of a plan fragment when assigned to a worker.
- *Source task*: a task that scan data source and generate pages. It uses the data source SPI to fetch data from the underlying data source with the help of a connector.
- *Split*: unit of data that a task process. It is the unit of parallelism and work assignment. Coordinator creates the list of splits with the metadata from the connector.  
Coordinator tracks all splits available for processing including splits generated as intermediate data.
- *Driver*: an instantiation of a pipeline of operators and performs the processing of the data in the split. A task instantiates a driver for each split.
- *Pipeline*: Sequence of Operators within a task
- *Operator*: processes input data to produces output data (pages) according to their semantics. e.g.
  - table scan
  - filters
  - joins
  - aggregations
  - projections
- *Page*: collection of rows in columnar format

Relationship is as follows:
- (Distributed) query plan has one or more Stages and stages have dependency
- Stage has one or more Tasks
- Coordinator creates the list of splits with the metadata from the connector
- Using the list of splits, Coordinator schedules tasks on the workers

# Table Statistics
https://prestosql.io/docs/current/optimizer/statistics.html
https://prestosql.io/docs/current/connector/hive.html#table-statistics
