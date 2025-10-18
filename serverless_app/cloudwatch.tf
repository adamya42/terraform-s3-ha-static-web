
# Define widget positions for regions

locals {
  widget_positions = {
    "us-east-1" = { read_y = 0, write_y = 6 },
    "us-west-2" = { read_y = 12, write_y = 18 }
  }

  widget_definitions = {
    for region, pos in local.widget_positions : region => {
      read_widget = {
        type   = "metric",
        x      = 0,
        y      = pos.read_y,
        width  = 24,
        height = 6,
        properties = {
          metrics = region == "us-east-1" && length(module.regional_infra_east.read_function_names) > 0 ? concat(
            [for func in module.regional_infra_east.read_function_names : ["AWS/Lambda", "Invocations", "FunctionName", func]],
            [for func in module.regional_infra_east.read_function_names : ["AWS/Lambda", "Errors", "FunctionName", func]],
            [for func in module.regional_infra_east.read_function_names : ["AWS/Lambda", "Duration", "FunctionName", func]]
            ) : region == "us-west-2" && length(module.regional_infra_west.read_function_names) > 0 ? concat(
            [for func in module.regional_infra_west.read_function_names : ["AWS/Lambda", "Invocations", "FunctionName", func]],
            [for func in module.regional_infra_west.read_function_names : ["AWS/Lambda", "Errors", "FunctionName", func]],
            [for func in module.regional_infra_west.read_function_names : ["AWS/Lambda", "Duration", "FunctionName", func]]
          ) : [],
          period = var.cloudwatch_period,
          stat   = var.metric_stat,
          region = region,
          title  = region == "us-east-1" && length(module.regional_infra_east.read_function_names) > 0 ? "Read Lambda Metrics for Function '${module.regional_infra_east.read_function_names[0]}' in Region '${region}'" : region == "us-west-2" && length(module.regional_infra_west.read_function_names) > 0 ? "Read Lambda Metrics for Function '${module.regional_infra_west.read_function_names[0]}' in Region '${region}'" : "No Read Lambda Metrics (${region})"
        }
      },
      write_widget = {
        type   = "metric",
        x      = 0,
        y      = pos.write_y,
        width  = 24,
        height = 6,
        properties = {
          metrics = region == "us-east-1" && length(module.regional_infra_east.write_function_names) > 0 ? concat(
            [for func in module.regional_infra_east.write_function_names : ["AWS/Lambda", "Invocations", "FunctionName", func]],
            [for func in module.regional_infra_east.write_function_names : ["AWS/Lambda", "Errors", "FunctionName", func]],
            [for func in module.regional_infra_east.write_function_names : ["AWS/Lambda", "Duration", "FunctionName", func]]
            ) : region == "us-west-2" && length(module.regional_infra_west.write_function_names) > 0 ? concat(
            [for func in module.regional_infra_west.write_function_names : ["AWS/Lambda", "Invocations", "FunctionName", func]],
            [for func in module.regional_infra_west.write_function_names : ["AWS/Lambda", "Errors", "FunctionName", func]],
            [for func in module.regional_infra_west.write_function_names : ["AWS/Lambda", "Duration", "FunctionName", func]]
          ) : [],
          period = var.cloudwatch_period,
          stat   = "Sum",
          region = region,
          title  = region == "us-east-1" && length(module.regional_infra_east.write_function_names) > 0 ? "Write Lambda Metrics (${region})" : region == "us-west-2" && length(module.regional_infra_west.write_function_names) > 0 ? "Write Lambda Metrics (${region})" : "No Write Lambda Metrics (${region})"
        }
      }
    }
  }
}
# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "ha_dashboard" {
  for_each = local.regions

  dashboard_name = "HighAvailabilityDashboard-${each.key}"

  dashboard_body = jsonencode({
    widgets = [
      local.widget_definitions[each.key].read_widget,
      local.widget_definitions[each.key].write_widget
    ]
  })

  depends_on = [
    module.regional_infra_east,
    module.regional_infra_west
  ]

}

