locals {
  enabled = module.this.enabled
}

resource "aws_glue_trigger" "this" {
  name          = module.this.id
  workflow_name = var.workflow_name
  type          = var.type
  schedule      = var.schedule

  enabled = local.enabled

  dynamic "predicate" {
    for_each = var.type == "CONDITIONAL" ? [1] : []
    content {

      dynamic "conditions" {
        for_each = var.conditions

        content {
          job_name = conditions.value["job_name"]
          state    = conditions.value["state"]
        }
      }

      logical = var.logical
    }
  }

  dynamic "actions" {
    for_each = var.actions

    content {
      job_name     = actions.value.job_name
      crawler_name = actions.value.crawler_name
      arguments    = actions.value.arguments
      timeout      = actions.value.timeout
    }
  }

  tags = module.this.tags
}