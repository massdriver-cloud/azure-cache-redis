resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.azure_virtual_network.specs.azure.region
  tags     = var.md_metadata.default_tags
}

resource "azurerm_redis_cache" "main" {
  name                          = var.md_metadata.name_prefix
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  redis_version                 = var.redis.redis_version
  replicas_per_primary          = var.redis.replicas_per_primary
  family                        = "P"
  capacity                      = var.redis.capacity
  sku_name                      = "Premium"
  minimum_tls_version           = "1.2"
  subnet_id                     = var.azure_virtual_network.data.infrastructure.default_subnet_id
  public_network_access_enabled = false
  shard_count                   = var.cluster.enable_cluster ? var.cluster.shard_count : 0
  tags                          = var.md_metadata.default_tags

  dynamic "redis_configuration" {
    for_each = var.redis.persistence ? [1] : []
    content {
      rdb_backup_enabled = var.redis.persistence_type == "RDB" ? true : false
      # Snapshot count seems to be a limitation, and can only be set to "1"
      # https://github.com/hashicorp/terraform-provider-azurerm/issues/19469
      rdb_backup_max_snapshot_count = var.redis.persistence_type == "RDB" ? 1 : null
      rdb_backup_frequency          = var.redis.persistence_type == "RDB" ? var.redis.rdb_persistence : null
      # Right now the connection string is required to be set, even if we're using RBAC.
      # Submitted a GitHub issue in the provider for this:
      # https://github.com/hashicorp/terraform-provider-azurerm/issues/20223
      rdb_storage_connection_string   = var.redis.persistence_type == "RDB" ? azurerm_storage_account.rdb[0].primary_connection_string : null
      aof_backup_enabled              = var.redis.persistence_type == "AOF" ? true : false
      aof_storage_connection_string_0 = var.redis.persistence_type == "AOF" ? azurerm_storage_account.aof0[0].primary_connection_string : null
      # Per MSFT docs, if a second storage account is "removed", then the first storage account should also be used as the second
      aof_storage_connection_string_1 = var.redis.persistence_type == "AOF" && var.redis.aof_persistence == true ? azurerm_storage_account.aof1[0].primary_connection_string : azurerm_storage_account.aof0[0].primary_connection_string
    }
  }

  identity {
    type = "SystemAssigned"
  }
}
