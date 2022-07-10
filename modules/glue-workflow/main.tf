locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_workflow
resource "aws_glue_workflow" "this" {
  count = local.enabled ? 1 : 0

  name                   = coalesce(var.workflow_name, module.this.id)
  description            = var.workflow_description
  default_run_properties = var.default_run_properties
  max_concurrent_runs    = var.max_concurrent_runs

  tags = module.this.tags
}
