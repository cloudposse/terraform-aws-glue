locals {
  enabled = module.this.enabled
}

resource "aws_glue_workflow" "this" {
  count = local.enabled ? 1 : 0

  name = var.name

  default_run_properties = var.default_run_properties

  max_concurrent_runs = var.max_concurrent_runs

  tags = module.this.tags
}
