locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database
resource "aws_glue_catalog_database" "this" {
  count = local.enabled ? 1 : 0

  name                            = coalesce(var.catalog_database_name, module.this.id)
  description                     = var.catalog_database_description
  catalog_id                      = var.catalog_id
  create_table_default_permission = var.create_table_default_permission
  location_uri                    = var.location_uri
  parameters                      = var.parameters
  target_database                 = var.target_database
}
