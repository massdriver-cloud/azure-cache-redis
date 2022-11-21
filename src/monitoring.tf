locals {
  automated_alarms = {
    cpu_metric_alert = {
      severity    = "1"
      frequency   = "PT1M"
      window_size = "PT5M"
      operator    = "GreaterThan"
      aggregation = "Average"
      threshold   = 90
    }
    memory_metric_alert = {
      severity    = "1"
      frequency   = "PT1M"
      window_size = "PT5M"
      operator    = "GreaterThan"
      aggregation = "Average"
      threshold   = 90
    }
    server_load_metric_alert = {
      severity    = "1"
      frequency   = "PT1M"
      window_size = "PT5M"
      operator    = "GreaterThan"
      aggregation = "Average"
      threshold   = 90
    }
  }
  alarms_map = {
    "AUTOMATED" = local.automated_alarms
    "DISABLED"  = {}
    "CUSTOM"    = lookup(var.monitoring, "alarms", {})
  }
  alarms = lookup(local.alarms_map, var.monitoring.mode, {})
}

module "alarm_channel" {
  source              = "github.com/massdriver-cloud/terraform-modules//azure-alarm-channel?ref=40d6e54"
  md_metadata         = var.md_metadata
  resource_group_name = azurerm_resource_group.main.name
}

module "cpu_metric_alert" {
  source                  = "github.com/massdriver-cloud/terraform-modules//azure-monitor-metrics-alarm?ref=40d6e54"
  scopes                  = [azurerm_redis_cache.main.id]
  resource_group_name     = azurerm_resource_group.main.name
  monitor_action_group_id = module.alarm_channel.id
  severity                = local.alarms.cpu_metric_alert.severity
  frequency               = local.alarms.cpu_metric_alert.frequency
  window_size             = local.alarms.cpu_metric_alert.window_size

  depends_on = [
    azurerm_redis_cache.main
  ]

  md_metadata  = var.md_metadata
  display_name = "CPU Usage"
  message      = "High CPU Usage"

  alarm_name       = "${var.md_metadata.name_prefix}-highProcessorTime"
  operator         = local.alarms.cpu_metric_alert.operator
  metric_name      = "allpercentprocessortime"
  metric_namespace = "Microsoft.Cache/Redis"
  aggregation      = local.alarms.cpu_metric_alert.aggregation
  threshold        = local.alarms.cpu_metric_alert.threshold

  dimensions = [{
    name     = "Primary"
    operator = "Include"
    values   = ["*"]
  }]
}

module "memory_metric_alert" {
  source                  = "github.com/massdriver-cloud/terraform-modules//azure-monitor-metrics-alarm?ref=40d6e54"
  scopes                  = [azurerm_redis_cache.main.id]
  resource_group_name     = azurerm_resource_group.main.name
  monitor_action_group_id = module.alarm_channel.id
  severity                = local.alarms.memory_metric_alert.severity
  frequency               = local.alarms.memory_metric_alert.frequency
  window_size             = local.alarms.memory_metric_alert.window_size

  depends_on = [
    azurerm_redis_cache.main
  ]

  md_metadata  = var.md_metadata
  display_name = "Memory Usage"
  message      = "High Memory Usage"

  alarm_name       = "${var.md_metadata.name_prefix}-highMemoryUsage"
  operator         = local.alarms.memory_metric_alert.operator
  metric_name      = "allusedmemorypercentage"
  metric_namespace = "Microsoft.Cache/Redis"
  aggregation      = local.alarms.memory_metric_alert.aggregation
  threshold        = local.alarms.memory_metric_alert.threshold
  dimensions = [{
    name     = "Primary"
    operator = "Include"
    values   = ["*"]
  }]
}

module "server_load_metric_alert" {
  source                  = "github.com/massdriver-cloud/terraform-modules//azure-monitor-metrics-alarm?ref=40d6e54"
  scopes                  = [azurerm_redis_cache.main.id]
  resource_group_name     = azurerm_resource_group.main.name
  monitor_action_group_id = module.alarm_channel.id
  severity                = local.alarms.server_load_metric_alert.severity
  frequency               = local.alarms.server_load_metric_alert.frequency
  window_size             = local.alarms.server_load_metric_alert.window_size

  depends_on = [
    azurerm_redis_cache.main
  ]

  md_metadata  = var.md_metadata
  display_name = "Server Load"
  message      = "High Server Load Usage"

  alarm_name       = "${var.md_metadata.name_prefix}-highServerLoadUsage"
  operator         = local.alarms.server_load_metric_alert.operator
  metric_name      = "serverLoad"
  metric_namespace = "Microsoft.Cache/Redis"
  aggregation      = local.alarms.server_load_metric_alert.aggregation
  threshold        = local.alarms.server_load_metric_alert.threshold
}
