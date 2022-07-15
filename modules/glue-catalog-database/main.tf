locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database
resource "aws_glue_catalog_database" "this" {
  count = local.enabled ? 1 : 0

  name         = coalesce(var.catalog_database_name, module.this.id)
  description  = var.catalog_database_description
  catalog_id   = var.catalog_id
  location_uri = var.location_uri
  parameters   = var.parameters

  dynamic "create_table_default_permission" {
    for_each = var.create_table_default_permission != null ? [true] : []

    content {
      permissions = try(var.create_table_default_permission.permissions, null)

      dynamic "principal" {
        for_each = try(var.create_table_default_permission.principal, null) != null ? [true] : []

        content {
          data_lake_principal_identifier = try(var.create_table_default_permission.principal.data_lake_principal_identifier, null)
        }
      }
    }
  }

  dynamic "target_database" {
    for_each = var.target_database != null ? [true] : []

    content {
      catalog_id    = var.target_database.catalog_id
      database_name = var.target_database.database_name
    }
  }
}
