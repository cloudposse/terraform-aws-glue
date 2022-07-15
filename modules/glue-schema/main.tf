locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_schema
resource "aws_glue_schema" "this" {
  count = local.enabled ? 1 : 0

  schema_name       = coalesce(var.schema_name, module.this.id)
  description       = var.schema_description
  registry_arn      = var.registry_arn
  data_format       = var.data_format
  compatibility     = var.compatibility
  schema_definition = var.schema_definition

  tags = module.this.tags
}
