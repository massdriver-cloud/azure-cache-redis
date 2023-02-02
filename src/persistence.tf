locals {
  max_length        = 21
  alphanumeric_name = substr(replace(var.md_metadata.name_prefix, "/[^a-z0-9]/", ""), 0, local.max_length)

  enable_rdb      = var.redis.persistence == "RDB"
  enable_aof      = var.redis.persistence == "AOF"
  enable_dual_aof = var.redis.persistence == "AOF_DUAL"
}

resource "azurerm_storage_account" "rdb" {
  count                     = local.enable_rdb ? 1 : 0
  name                      = "${local.alphanumeric_name}rdb"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  account_kind              = "StorageV2"
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = var.md_metadata.default_tags

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    default_action = "Deny"
    # Enabling RBAC for redis -> storage account adds the redis to the "Azure Trusted Services" list
    # which allows the redis cache to bypass the network ACLs:
    # https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal#grant-access-to-trusted-azure-services
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    virtual_network_subnet_ids = [var.azure_virtual_network.data.infrastructure.default_subnet_id]
  }
}

resource "azurerm_role_assignment" "rdb" {
  count                = local.enable_rdb ? 1 : 0
  scope                = azurerm_storage_account.rdb[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_redis_cache.main.identity.0.principal_id
}

resource "azurerm_storage_account" "aof0" {
  count                     = local.enable_aof || local.enable_dual_aof ? 1 : 0
  name                      = "${local.alphanumeric_name}aof0"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  account_kind              = "StorageV2"
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = var.md_metadata.default_tags

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    virtual_network_subnet_ids = [var.azure_virtual_network.data.infrastructure.default_subnet_id]
  }
}

resource "azurerm_role_assignment" "aof0" {
  count                = local.enable_aof || local.enable_dual_aof ? 1 : 0
  scope                = azurerm_storage_account.aof0[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_redis_cache.main.identity.0.principal_id
}

resource "azurerm_storage_account" "aof1" {
  count                     = local.enable_dual_aof ? 1 : 0
  name                      = "${local.alphanumeric_name}aof1"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  account_kind              = "StorageV2"
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = var.md_metadata.default_tags

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    virtual_network_subnet_ids = [var.azure_virtual_network.data.infrastructure.default_subnet_id]
  }
}

resource "azurerm_role_assignment" "aof1" {
  count                = local.enable_dual_aof ? 1 : 0
  scope                = azurerm_storage_account.aof1[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_redis_cache.main.identity.0.principal_id
}
