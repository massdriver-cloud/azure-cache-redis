locals {
  scope_config = {
    severity    = "1"
    frequency   = "PT1M"
    window_size = "PT5M"
  }
  metric_config = {
    operator              = "GreaterThan"
    aggregation           = "Average"
    threshold_cpu         = 90
    threshold_memory      = 90
    threshold_server_load = 90
  }
}

module "cpu_metric_alert" {
  source              = "github.com/massdriver-cloud/terraform-modules//azure-monitor-metrics-alarm?ref=c46bc59"
  scopes              = [azurerm_redis_cache.main.id]
  resource_group_name = azurerm_resource_group.main.name
  severity            = local.scope_config.severity
  frequency           = local.scope_config.frequency
  window_size         = local.scope_config.window_size

  depends_on = [
    azurerm_redis_cache.main
  ]

  md_metadata     = var.md_metadata
  message         = "High CPU Usage"

  alarm_name       = "${var.md_metadata.name_prefix}-highProcessorTime"
  operator         = local.metric_config.operator
  metric_name      = "allpercentprocessortime"
  metric_namespace = "Microsoft.Cache/Redis"
  aggregation      = local.metric_config.aggregation
  threshold        = local.metric_config.threshold_cpu

  dimensions = [{
    name     = "Primary"
    operator = "Include"
    values   = ["*"]
  }]
}

module "memory_metric_alert" {
  source              = "github.com/massdriver-cloud/terraform-modules//azure-monitor-metrics-alarm?ref=c46bc59"
  scopes              = [azurerm_redis_cache.main.id]
  resource_group_name = azurerm_resource_group.main.name
  severity            = local.scope_config.severity
  frequency           = local.scope_config.frequency
  window_size         = local.scope_config.window_size

  depends_on = [
    azurerm_redis_cache.main
  ]

  md_metadata     = var.md_metadata
  message         = "High Memory Usage"

  alarm_name       = "${var.md_metadata.name_prefix}-highMemoryUsage"
  operator         = local.metric_config.operator
  metric_name      = "allusedmemorypercentage"
  metric_namespace = "Microsoft.Cache/Redis"
  aggregation      = local.metric_config.aggregation
  threshold        = local.metric_config.threshold_memory

  dimensions = [{
    name     = "Primary"
    operator = "Include"
    values   = ["*"]
  }]
}

module "server_load_metric_alert" {
  source              = "github.com/massdriver-cloud/terraform-modules//azure-monitor-metrics-alarm?ref=c46bc59"
  scopes              = [azurerm_redis_cache.main.id]
  resource_group_name = azurerm_resource_group.main.name
  severity            = local.scope_config.severity
  frequency           = local.scope_config.frequency
  window_size         = local.scope_config.window_size

  depends_on = [
    azurerm_redis_cache.main
  ]

  md_metadata     = var.md_metadata
  message         = "High Server Load Usage"

  alarm_name       = "${var.md_metadata.name_prefix}-highServerLoadUsage"
  operator         = local.metric_config.operator
  metric_name      = "serverLoad"
  metric_namespace = "Microsoft.Cache/Redis"
  aggregation      = local.metric_config.aggregation
  threshold        = local.metric_config.threshold_server_load
}
