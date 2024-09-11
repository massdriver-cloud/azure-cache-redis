// Auto-generated variable declarations from massdriver.yaml
variable "azure_service_principal" {
  type = object({
    data = object({
      client_id       = string
      client_secret   = string
      subscription_id = string
      tenant_id       = string
    })
    specs = object({})
  })
}
variable "azure_virtual_network" {
  type = object({
    data = object({
      infrastructure = object({
        cidr              = string
        default_subnet_id = string
        id                = string
      })
    })
    specs = optional(object({
      azure = optional(object({
        region = string
      }))
    }))
  })
}
variable "cluster" {
  type = object({
    enable_cluster = bool
    shard_count    = optional(number)
  })
}
variable "md_metadata" {
  type = object({
    default_tags = object({
      managed-by  = string
      md-manifest = string
      md-package  = string
      md-project  = string
      md-target   = string
    })
    deployment = object({
      id = string
    })
    name_prefix = string
    observability = object({
      alarm_webhook_url = string
    })
    package = object({
      created_at             = string
      deployment_enqueued_at = string
      previous_status        = string
      updated_at             = string
    })
    target = object({
      contact_email = string
    })
  })
}
variable "monitoring" {
  type = object({
    mode = optional(string)
    alarms = optional(object({
      cpu_metric_alert = optional(object({
        aggregation = string
        frequency   = string
        operator    = string
        severity    = number
        threshold   = number
        window_size = string
      }))
      memory_metric_alert = optional(object({
        aggregation = string
        frequency   = string
        operator    = string
        severity    = number
        threshold   = number
        window_size = string
      }))
      server_load_metric_alert = optional(object({
        aggregation = string
        frequency   = string
        operator    = string
        severity    = number
        threshold   = number
        window_size = string
      }))
    }))
  })
}
variable "redis" {
  type = object({
    capacity             = number
    non_ssl_port         = bool
    persistence          = string
    redis_version        = string
    replicas_per_primary = number
    rdb_persistence      = optional(number)
  })
}
