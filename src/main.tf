locals {
  sku = {
    family   = "P"
    sku_name = "Premium"
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.vnet.specs.azure.region
}

resource "azurerm_redis_cache" "main" {
  name                = var.md_metadata.name_prefix
  location            = var.vnet.specs.azure.region
  resource_group_name = azurerm_resource_group.main.name

  redis_version        = var.redis_version
  replicas_per_primary = var.replicas_per_primary
  family               = local.sku.family
  capacity             = var.capacity
  sku_name             = local.sku.sku_name
  subnet_id            = var.vnet.data.infrastructure.default_subnet_id

  # for some reason this defaults to true. Setting to false to prevent internet access
  public_network_access_enabled = false

  shard_count = var.enable_cluster ? var.shard_count : 0

  tags = var.md_metadata.default_tags
}
