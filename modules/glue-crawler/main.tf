locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler
resource "aws_glue_crawler" "this" {
  count = local.enabled ? 1 : 0

  name                   = coalesce(var.crawler_name, module.this.id)
  description            = var.crawler_description
  database_name          = var.database_name
  role                   = var.role
  schedule               = var.schedule
  classifiers            = var.classifiers
  configuration          = var.configuration
  dynamodb_target        = var.dynamodb_target
  jdbc_target            = var.jdbc_target
  s3_target              = var.s3_target
  mongodb_target         = var.mongodb_target
  catalog_target         = var.catalog_target
  delta_target           = var.delta_target
  schema_change_policy   = var.schema_change_policy
  lineage_configuration  = var.lineage_configuration
  recrawl_policy         = var.recrawl_policy
  security_configuration = var.security_configuration
  table_prefix           = var.table_prefix

  tags = module.this.tags
}
