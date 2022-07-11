locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler
resource "aws_glue_crawler" "this" {
  count = local.enabled ? 1 : 0

  name          = coalesce(var.crawler_name, module.this.id)
  description   = var.crawler_description
  database_name = var.database_name
  role          = var.role

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
