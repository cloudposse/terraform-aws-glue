locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job
resource "aws_glue_job" "this" {
  count = local.enabled ? 1 : 0

  name                      = coalesce(var.job_name, module.this.id)
  description               = var.job_description
  connections               = var.connections
  default_arguments         = var.default_arguments
  non_overridable_arguments = var.non_overridable_arguments
  glue_version              = var.glue_version
  timeout                   = var.timeout
  number_of_workers         = var.number_of_workers
  worker_type               = var.worker_type
  max_capacity              = var.max_capacity
  role_arn                  = var.role_arn
  security_configuration    = var.security_configuration
  max_retries               = var.max_retries

  command {
    name            = try(var.command.name, null)
    python_version  = try(var.command.python_version, null)
    script_location = var.command.script_location
  }

  dynamic "notification_property" {
    for_each = var.notification_property != null ? [true] : []
    content {
      notify_delay_after = var.notification_property.notify_delay_after
    }
  }

  dynamic "execution_property" {
    for_each = var.execution_property != null ? [true] : []
    content {
      max_concurrent_runs = var.execution_property.max_concurrent_runs
    }
  }

  tags = module.this.tags
}
