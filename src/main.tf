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
  enable_non_ssl_port           = try(var.redis.non_ssl_port, null)
  shard_count                   = var.cluster.enable_cluster ? var.cluster.shard_count : 0
  tags                          = var.md_metadata.default_tags

  dynamic "redis_configuration" {
    for_each = local.enable_rdb ? [1] : []
    content {
      rdb_backup_enabled            = true
      rdb_backup_max_snapshot_count = 1
      rdb_backup_frequency          = var.redis.rdb_persistence
      rdb_storage_connection_string = azurerm_storage_account.rdb[0].primary_connection_string
    }
  }

  # Right now the connection string is required to be set, even if we're using RBAC.
  # Submitted a GitHub issue in the provider for this:
  # https://github.com/hashicorp/terraform-provider-azurerm/issues/20223

  dynamic "redis_configuration" {
    for_each = local.enable_aof ? [1] : []
    content {
      aof_backup_enabled              = true
      aof_storage_connection_string_0 = azurerm_storage_account.aof0[0].primary_connection_string
    }
  }

  dynamic "redis_configuration" {
    for_each = local.enable_dual_aof ? [1] : []
    content {
      aof_backup_enabled              = true
      aof_storage_connection_string_0 = azurerm_storage_account.aof0[0].primary_connection_string
      aof_storage_connection_string_1 = azurerm_storage_account.aof1[0].primary_connection_string
    }
  }

  identity {
    type = "SystemAssigned"
  }
}
