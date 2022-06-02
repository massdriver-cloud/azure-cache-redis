locals {
  data_authentication = {
    username = ""
    password = azurerm_redis_cache.main.primary_access_key
    hostname = azurerm_redis_cache.main.hostname
    port     = azurerm_redis_cache.main.port
  }
  data_security = {}
}

resource "massdriver_artifact" "authentication" {
  field                = "authentication"
  provider_resource_id = azurerm_redis_cache.main.id
  type                 = "redis-authentication"
  name                 = "Redis Cache ${var.md_metadata.name_prefix} (${azurerm_redis_cache.main.id})"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          ari = azurerm_redis_cache.main.id
        }
        authentication = local.data_authentication
        security       = local.data_security
      }
      specs = {
        cache = {
          "engine"  = "redis"
          "version" = azurerm_redis_cache.main.redis_version
        }
      }
    }
  )
}
