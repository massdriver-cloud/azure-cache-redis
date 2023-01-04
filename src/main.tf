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
  subnet_id                     = var.azure_virtual_network.data.infrastructure.default_subnet_id
  public_network_access_enabled = false
  shard_count                   = var.cluster.enable_cluster ? var.cluster.shard_count : 0
  tags                          = var.md_metadata.default_tags

  identity {
    type = "SystemAssigned"
  }
}
