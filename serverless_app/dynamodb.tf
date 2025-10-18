# DynamoDB Global Table (us-east-1 + replica in us-west-2)
resource "aws_dynamodb_table" "ha_table" {
  # provider     = aws.primary
  name         = var.ha_table_name
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "ItemId"
  attribute {
    name = "ItemId"
    type = "S"
  }
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  replica {
    region_name = var.secondary_region
  }
}
