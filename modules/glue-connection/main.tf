locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_connection
resource "aws_glue_connection" "this" {
  count = local.enabled ? 1 : 0

  name                  = coalesce(var.connection_name, module.this.id)
  description           = var.connection_description
  catalog_id            = var.catalog_id
  connection_type       = var.connection_type
  connection_properties = var.connection_properties
  match_criteria        = var.match_criteria

  dynamic "physical_connection_requirements" {
    for_each = var.physical_connection_requirements != null ? [true] : []

    content {
      availability_zone      = try(var.physical_connection_requirements.availability_zone, null)
      security_group_id_list = try(var.physical_connection_requirements.security_group_id_list, null)
      subnet_id              = try(var.physical_connection_requirements.subnet_id, null)
    }
  }

  tags = module.this.tags
}
