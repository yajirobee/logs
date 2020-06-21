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
Query plan -> Distributed query plan

- Distributed query plan
  - Stages
    - Tasks
  - Dependency tree of stages

Source stage -> pages (collection of rows in columnar format)

Split: unit of data that a task process. Coordinator creates the list of splits with the metadata from the connector.  
Coordinator tracks all splits available for processing including splits generated as intermediate data.

Operators: Produces pages
  - filters drop rows
  - projections produce pages with new derived columns
  
Pipeline: Sequence of Operators within a task

Driver: an instantiation of a pipeline of operators and performs the processing of the data in the split. A task instantiates for each split.

# Table Statistics
https://prestosql.io/docs/current/optimizer/statistics.html
