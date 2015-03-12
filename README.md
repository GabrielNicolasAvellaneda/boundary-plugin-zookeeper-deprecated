Boundary Zookeeper Plugin
-----------------------------
Collects metrics from Zookeeper server using the **mntr** command. Take a look at  [Zookeeper Administrator's Guide](http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html) for details

### Platforms

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |         |         |      |

### Prerequisites

- Zookeeper 3.4+

### Plugin Configuration

In order the plugin to collect statistics from Zookeeper server, it needs access to the service stats API endpoint.

|Field Name     |Description                                         |
|:--------------|:---------------------------------------------------|
|port   |Zookeeper service port -          default: 2185 or maybe 2181     |
|host   |Zookeeper service host -          default: localhost|
|pollInterval   |How often to query the Zookeeper service for metrics|

### Metrics Collected

|Metric Name                  |Description                                                              |
|:----------------------------|:------------------------------------------------------------------------|
|ZK_WATCH_COUNT               |Total amount of watches in zookeeper                                     |
|ZK_NUM_ALIVE_CONNECTIONS     |Number of active connections in Zookeeper                                |
|ZK_OPEN_FILE_DESCRIPTOR_COUNT|Total amount of file descriptors open in the system reported by zookeeper|
|ZK_PACKETS_SENT              |Total number of packages sent from Zookeeper                             |
|ZK_PACKETS_RECEIVED          |Total number of packages received in Zookeeper                           |
|ZK_MIN_LATENCY               |The minimum latency measured by Zookeeper                                |
|ZK_EPHEMERALS_COUNT          |The total amount of ephemerals in Zookeeper                              |
|ZK_ZNODE_COUNT               |Total number of data registers in Zookeeper                              |
|ZK_MAX_FILE_DESCRIPTOR_COUNT |Total maximum number of file descriptors allowed to open                  |
