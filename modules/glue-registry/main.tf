locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_registry
resource "aws_glue_registry" "this" {
  count = local.enabled ? 1 : 0

  registry_name = coalesce(var.registry_name, module.this.id)
  description   = var.registry_description

  tags = module.this.tags
}
