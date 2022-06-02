locals {
  threshold_cpu    = 90
  threshold_memory = 90
}

module "cpu_metric_alert" {
  source              = "../../../provisioners/terraform/modules/azure-monitor-metrics-alarm"
  scopes              = azurerm_redis_cache.main.id
  resource_group_name = azurerm_resource_group.main.name
  severity            = "1"
  frequency           = "PT1M"
  window_size         = "PT5M"

  depends_on = [
    azurerm_redis_cache.main
  ]

  md_metadata     = var.md_metadata
  action_group_id = var.vnet.data.observability.alarm_monitor_action_group_ari
  message         = "High CPU Usage"

  alarm_name       = "${var.md_metadata.name_prefix}-highProcessorTime"
  operator         = "GreaterThan"
  metric_name      = "allpercentprocessortime"
  metric_namespace = "Microsoft.Cache/Redis"
  aggregation      = "Average"
  threshold        = local.threshold_cpu

  dimensions = [{
    name     = "Primary"
    operator = "Include"
    values   = ["*"]
  }]
}

module "memory_metric_alert" {
  source              = "../../../provisioners/terraform/modules/azure-monitor-metrics-alarm"
  scopes              = azurerm_redis_cache.main.id
  resource_group_name = azurerm_resource_group.main.name
  severity            = "1"
  frequency           = "PT1M"
  window_size         = "PT5M"

  depends_on = [
    azurerm_redis_cache.main
  ]

  md_metadata     = var.md_metadata
  action_group_id = var.vnet.data.observability.alarm_monitor_action_group_ari
  message         = "High Memory Usage"

  alarm_name       = "${var.md_metadata.name_prefix}-highMemoryUsage"
  operator         = "GreaterThan"
  metric_name      = "allusedmemorypercentage"
  metric_namespace = "Microsoft.Cache/Redis"
  aggregation      = "Average"
  threshold        = local.threshold_memory

  dimensions = [{
    name     = "Primary"
    operator = "Include"
    values   = ["*"]
  }]
}
