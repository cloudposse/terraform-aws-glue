locals {
  enabled = module.this.enabled
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job
resource "aws_glue_job" "this" {
  count = local.enabled ? 1 : 0

  name                      = coalesce(var.job_name, module.this.id)
  description               = var.job_description
  command                   = var.command
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
  execution_property        = var.execution_property
  max_retries               = var.max_retries
  notification_property     = var.notification_property

  tags = module.this.tags
}
