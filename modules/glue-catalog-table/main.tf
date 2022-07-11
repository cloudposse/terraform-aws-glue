locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table
resource "aws_glue_catalog_table" "this" {
  count = local.enabled ? 1 : 0

  name               = coalesce(var.catalog_table_name, module.this.id)
  description        = var.catalog_table_description
  database_name      = var.database_name
  catalog_id         = var.catalog_id
  owner              = var.owner
  parameters         = var.parameters
  partition_index    = var.partition_index
  partition_keys     = var.partition_keys
  retention          = var.retention
  storage_descriptor = var.storage_descriptor
  table_type         = var.table_type
  target_table       = var.target_table
  view_expanded_text = var.view_expanded_text
  view_original_text = var.view_original_text
}
