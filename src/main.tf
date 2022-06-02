locals {
  redis_size_to_capacity = {
    "6 GB"   = 1
    "13 GB"  = 2
    "26 GB"  = 3
    "53 GB"  = 4
    "120 GB" = 5
  }
  capacity_lookup = lookup(local.redis_size_to_capacity, var.capacity, "")

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
  capacity             = local.capacity_lookup
  sku_name             = local.sku.sku_name
  subnet_id            = var.vnet.data.infrastructure.default_subnet_id

  tags = var.md_metadata.default_tags
}
