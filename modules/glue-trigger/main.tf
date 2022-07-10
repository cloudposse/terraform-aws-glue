locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_trigger
resource "aws_glue_trigger" "this" {
  count = local.enabled ? 1 : 0

  name              = coalesce(var.trigger_name, module.this.id)
  description       = var.trigger_description
  workflow_name     = var.workflow_name
  type              = var.type
  schedule          = var.schedule
  enabled           = var.trigger_enabled
  start_on_creation = var.type == "ON_DEMAND" ? false : var.start_on_creation

  dynamic "predicate" {
    for_each = var.type == "CONDITIONAL" ? [1] : []
    content {
      dynamic "conditions" {
        for_each = var.conditions

        content {
          job_name         = try(conditions.value.job_name, null)
          state            = try(conditions.value.state, null)
          crawler_name     = try(conditions.value.crawler_name, null)
          crawl_state      = try(conditions.value.crawl_state, null)
          logical_operator = try(conditions.value.logical_operator, null)
        }
      }

      logical = var.logical
    }
  }

  dynamic "actions" {
    for_each = var.actions

    content {
      job_name               = try(actions.value.job_name, null)
      crawler_name           = try(actions.value.crawler_name, null)
      arguments              = try(actions.value.arguments, null)
      security_configuration = try(actions.value.security_configuration, null)
      notification_property  = try(actions.value.notification_property, null)
      timeout                = try(actions.value.timeout, null)
    }
  }

  tags = module.this.tags
}
