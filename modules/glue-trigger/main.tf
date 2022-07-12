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
    for_each = var.predicate != null ? [true] : []

    content {
      logical = try(var.predicate.logical, null)

      dynamic "conditions" {
        for_each = var.predicate.conditions

        content {
          job_name         = try(conditions.value.job_name, null)
          state            = try(conditions.value.state, null)
          crawler_name     = try(conditions.value.crawler_name, null)
          crawl_state      = try(conditions.value.crawl_state, null)
          logical_operator = try(conditions.value.logical_operator, null)
        }
      }
    }
  }

  dynamic "actions" {
    for_each = var.actions

    content {
      job_name               = try(actions.value.job_name, null)
      crawler_name           = try(actions.value.crawler_name, null)
      arguments              = try(actions.value.arguments, null)
      security_configuration = try(actions.value.security_configuration, null)
      timeout                = try(actions.value.timeout, null)

      dynamic "notification_property" {
        for_each = try(actions.value.notification_property, null) != null ? [true] : []
        content {
          notify_delay_after = try(actions.value.notification_property.notify_delay_after, null)
        }
      }
    }
  }

  dynamic "event_batching_condition" {
    for_each = var.event_batching_condition != null ? [true] : []

    content {
      batch_size   = var.event_batching_condition.batch_size
      batch_window = try(var.event_batching_condition.batch_window, null)
    }
  }

  tags = module.this.tags
}
