resource "aws_acm_certificate" "multi_region" {
  # for_each          = local.instances
  domain_name       = "api.${var.domain_name}"
  validation_method = "DNS"
  #provider = each.value

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "selected" {
  name = "${var.domain_name}." # Example: example.com.
}



# # This block is commented out because it is not needed for multi-region certificates.
# # It is included here for reference in case you want to use it for a single-region certificate. 
#
# resource "aws_route53_record" "api_cert_validation" {
#     for_each = {
#         for cert in aws_acm_certificate.api_cert.domain_validation_options : cert.domain_name => {
#             name    = cert.resource_record_name
#             type    = cert.resource_record_type
#             record   = cert.resource_record_value
#         }
#     }
#     zone_id = data.aws_route53_zone.selected.zone_id
#     name    = each.value.name
#     type    = each.value.type
#     ttl     = 60
#     records = [each.value.record]
#     provider = aws.primary   
#     allow_overwrite = true
# }

resource "aws_route53_record" "validation" {
  # for_each = local.instances
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = tolist(aws_acm_certificate.multi_region.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.multi_region.domain_validation_options)[0].resource_record_type
  ttl     = 60
  records = [tolist(aws_acm_certificate.multi_region.domain_validation_options)[0].resource_record_value]

  allow_overwrite = true
  # DNS records are created in Route 53, which is global, so we can pick any provider.
  # provider = aws.us-east-1 # or any region you prefer [Picking provider for consistency]
}


# # This block is commented out because it is not needed for multi-region certificates.
# # It is included here for reference in case you want to use it for a single-region certificate. 
#
# resource "aws_acm_certificate_validation" "api_cert_validation_secondary" {
#   certificate_arn         = aws_acm_certificate.api_cert_secondary.arn
#   validation_record_fqdns = [for record in aws_route53_record.api_cert_validation_secondary: record.fqdn]
#   provider = aws.us-west-2
# }


resource "aws_acm_certificate_validation" "multi_region" {
  for_each        = local.instances
  certificate_arn = aws_acm_certificate.multi_region.arn
  validation_record_fqdns = [
    aws_route53_record.validation.fqdn
  ]
  #provider = each.value
}