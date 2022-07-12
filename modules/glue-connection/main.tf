locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_connection
resource "aws_glue_connection" "this" {
  count = local.enabled ? 1 : 0

  name                             = coalesce(var.connection_name, module.this.id)
  description                      = var.connection_description
  catalog_id                       = var.catalog_id
  connection_type                  = var.connection_type
  connection_properties            = var.connection_properties
  match_criteria                   = var.match_criteria
  physical_connection_requirements = var.physical_connection_requirements

  tags = module.this.tags
}
