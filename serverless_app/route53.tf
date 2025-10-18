
data "aws_route53_zone" "selected" {
  name = "${var.domain_name}." # Example: example.com.
}

resource "aws_route53_record" "api_failover_west" {
  for_each = local.regions
  zone_id  = data.aws_route53_zone.selected.zone_id
  name     = "api.${var.domain_name}"
  type     = "A"

  alias {
    name                   = each.key == "us-east-1" ? module.regional_infra_east.api_gateway_domain_target : module.regional_infra_west.api_gateway_domain_target
    zone_id                = each.key == "us-east-1" ? module.regional_infra_east.api_gateway_domain_zone_id : module.regional_infra_west.api_gateway_domain_zone_id
    evaluate_target_health = true
  }

  set_identifier  = each.key
  health_check_id = aws_route53_health_check.multi_region[each.key].id

  failover_routing_policy {
    type = local.failover_type[each.key]
  }
}

resource "aws_route53_health_check" "multi_region" {
  for_each          = local.regions
  fqdn              = each.key == "us-east-1" ? module.regional_infra_east.api_gateway_domain_target : module.regional_infra_west.api_gateway_domain_target #each.key == "us-east-1" ? "primary_api_gw_dns" : "secondary_api_gw_dns"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/prod/read"
  failure_threshold = 3
  request_interval  = 30
}
