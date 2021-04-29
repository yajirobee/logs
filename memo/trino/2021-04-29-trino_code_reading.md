---
layout: memo
title: Trino Code Reading
---

Memo for Trino code reading

Following memo is based on Trino 355 which is the latest version as of April 29, 2021.

# Connector Implementation
- io.trino.spi.Plugin  
Entory point of a Plugin. Provides `io.trino.spi.connector.ConnectorFactory`  
configuration is provided here.  
  - reference: [SPI overview](https://trino.io/docs/current/develop/spi-overview.html)
- io.trino.spi.connector.Connector / ConnectorFactory  
`Collector` provides the instances of the following services:
  - io.trino.spi.connector.ConnectorMetadata
  - io.trino.spi.connector.ConnectorSplitManager
  - io.trino.spi.connector.ConnectorHandleResolver
  - io.trino.spi.connector.ConnectorRecordSetProvider
  - reference: [Connectors](https://trino.io/docs/current/develop/connectors.html)

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
- (Distributed) query plan has one or more Stages and Stages have dependency
- Stage has one or more Tasks
- Coordinator creates the list of splits with the metadata from the connector
- Using the list of splits, Coordinator schedules tasks on the workers
- Task creates a Driver for each Split

# Table Statistics
- [Available Table statistics](https://trino.io/docs/current/optimizer/statistics.html)
- [Table statistics for hive connector](https://trino.io/docs/current/connector/hive.html#table-statistics)

# Server
## Bootstrap
- io.trino.server.Server#doStart
  - add io.trino.server.ServerMainModule
    - for coordinator, install CoordinatorModule
    - for worker, install WorkerModule
- io.trino.server.PluginManager#loadPlugins

## Query
### Coordinator
- receive REST API request POST /v1/statement
- io.trino.dispatcher.QueuedStatementResource
  - create query ID
  - respond queued URI
- receive REST API request queued/{queryId}/{slug}/{token}
  - Query#waitForDispatched
  - io.trino.dispatcher.DispatchManager#createQuery
    - decode session
    - select resource group
    - io.trino.dispatcher.LocalDispatchQueryFactory
      - io.trino.execution.SqlQueryExecution is asynchronously created by Future
      - io.trino.dispatcher.LocalDispatchQuery is created 
  - io.trino.execution.resourcegroups.ResourceGroupManager(InternalResourceGroupManager)#submit
  - io.trino.execution.resourcegroups.InternalResourceGroup#run
  - io.trino.dispatcher.LocalDispatchQuery#startWaitingForResources
    - wait for query execution to finish construction
    - wait for minimum workers
    - startExecution -> querySubmitter#accept (SqlQueryManager#createQuery)
  - io.trino.execution.SqlQueryManager#createQuery
  - io.trino.execution.QueryExecution#start
    - for query (select / insert /delete): io.trino.execution.SqlQueryExecution
    - for DDL: io.trino.execution.DataDefinitionExecution
    - statemachine: transition to planning

#### Planning
##### Query processing
- io.trino.execution.SqlQueryExecution#planQuery
  - io.trino.sql.planner.LogicalPlanner#plan
  - io.trino.sql.planner.InputExtractor#extractInputs
    - visit plan nodes
  - io.trino.sql.planner.PlanFragmenter#createSubPlans
- io.trino.execution.SqlQueryExecution#planDistribution
  - io.trino.sql.planner.DistributedExecutionPlanner#plan -> StageExecutionPlan
    - get splits for this fragment, this is lazy so split assignments aren't actually calculated here  
      io.trino.sql.planner.DistributedExecutionPlanner.Visitor#visitScanAndFilter
      - io.trino.split.SplitManager#getSplits
        - call ConnectorSplitManager#getSplits
    - create child stages
    - extract TableInfo
  - set queryScheduler  
    io.trino.execution.scheduler.SqlQueryScheduler#createSqlQueryScheduler

##### DDL
- io.trino.execution.DataDefinitionExecution#start
- io.trino.execution.DataDefinitionTask#execute

e.g. CREATE TABLE
- list table elements
- get table properties
  - io.trino.metadata.TablePropertyManager#getProperties  
    accept properties provided by io.trino.spi.connector.Connector#getTableProperties
- create table
  - io.trino.metadata.MetadataManager#createTable
  - io.trino.spi.connector.ConnectorMetadata#createTable

#### Execution
Describing query processing, not DDL
- SqlQueryScheduler#start

# Connector
## Hive Connector
- IO queue is in io.trino.plugin.hive.HiveSplitSource
  - per query IO queue
- File format is detected on io.trino.plugin.hive.HivePageSourceProvider#createHivePageSource
