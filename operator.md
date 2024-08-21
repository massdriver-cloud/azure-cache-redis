## Azure Cache for Redis

Azure Cache for Redis is a managed, in-memory cache service that can be used to improve the performance and scalability of applications. It allows you to store and retrieve data from a high-throughput and low-latency cache and supports features such as persistent storage and failover.

### Design Decisions

1. **System-Assigned Managed Identity**: The Redis Cache uses a system-assigned identity for secure and streamlined resource access.
2. **Networking**: By default, the Redis Cache is placed within a specified subnet in an Azure Virtual Network to control access.
3. **Data Persistence**: The module supports RDB and AOF persistence configurations. RDB (Redis Database Backup) creates snapshots of your cache at specified intervals, while AOF (Append Only File) logs every write operation received by the server.
4. **Monitoring and Alerts**: Automated alarms for CPU usage, memory usage, and server load are predefined.

### Runbook

#### Redis Cache Connection Issues

If you experience connection issues to the Azure Redis Cache instance, the following Azure CLI and Redis CLI commands can help troubleshoot the problem.

Check the status of the Redis Cache instance:

```sh
az redis show --name <redis-cache-name> --resource-group <resource-group-name>
```

**Expected Output**: The status of the Redis Cache instance should be "Running."

Attempt to connect using the Redis CLI:

```sh
redis-cli -h <redis-cache-hostname> -p <redis-cache-port> -a <redis-cache-password>
```

**Expected Output**: A successful Redis connection prompt (`<hostname>:<port>`).

#### High CPU Usage

To determine if your Redis Cache is experiencing high CPU usage, use the Azure Monitor metrics.

Check Redis Cache CPU usage with Azure CLI:

```sh
az monitor metrics list --resource <redis-cache-id> --metric allpercentprocessortime --interval PT1H
```

**Expected Output**: Metrics data showing CPU usage over the specified interval.

#### High Memory Usage

High memory usage can degrade the performance of the Redis Cache. Verify memory usage with the following command:

```sh
az monitor metrics list --resource <redis-cache-id> --metric allusedmemorypercentage --interval PT1H
```

**Expected Output**: Metrics data showing memory usage over the specified interval.

#### Unable to Perform Backup

Ensure that the storage account used for Redis persistence is correctly configured.

Verify storage account configuration:

```sh
az storage account show --name <storage-account-name> --resource-group <resource-group-name>
```

**Expected Output**: The storage account details with correct configuration parameters (e.g., Premium, LRS, available access keys).

Check Redis backup settings:

```redis
CONFIG GET dir
CONFIG GET dbfilename
```

**Expected Output**: Successfully retrieved configuration settings for the backup directory and database filename.

#### Slow Performance

If the Redis Cache is experiencing slow performance, check the server load and connected clients.

Monitor server load:

```sh
az monitor metrics list --resource <redis-cache-id> --metric serverLoad --interval PT1H
```

**Expected Output**: Metrics data indicating server load over the specified interval.

Check connected clients using Redis CLI:

```redis
CLIENT LIST
```

**Expected Output**: List of clients connected to the Redis Cache, including their details such as address and idle time.

