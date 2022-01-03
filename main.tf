locals {
  enabled           = module.this.enabled
  logging_enabled   = var.logging_enabled
  metrics_enabled   = var.metrics_enabled
  script_overridden = local.enabled && var.script_location == ""
  script_location   = local.script_overridden ? "s3://${var.script_s3_bucket}/${aws_s3_bucket_object.this[0].id}" : var.script_location
  metrics_arguments = {
    "--enable-metrics" = ""
  }
  logging_arguments = {
    "--continuous-log-logGroup"          = module.cloudwatch_log_group.log_group_name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
  }
  job_arguments = merge(
    var.job_default_arguments,
    local.logging_enabled ? local.logging_arguments : {},
    local.metrics_enabled ? local.metrics_arguments : {}
  )
}

resource "aws_glue_workflow" "this" {
  count = local.enabled ? 1 : 0

  name = module.this.id
}

resource "aws_glue_trigger" "trigger_start" {
  name          = "${module.this.id}-trigger-start"
  workflow_name = aws_glue_workflow.etl.name
  type          = "SCHEDULED"

  enabled = local.enabled

  schedule = var.cron_schedule

  actions {
    job_name = aws_glue_job.etl_job.name
  }

  tags = module.this.tags
}

resource "aws_glue_trigger" "trigger_stop" {
  name          = "${module.this.id}-trigger-stop"
  workflow_name = aws_glue_workflow.etl.name
  type          = "CONDITIONAL"

  enabled = local.enabled

  predicate {
    conditions {
      job_name = aws_glue_job.etl_job.name
      state    = "SUCCEEDED"
    }
  }

  actions {
    crawler_name = var.crawler_name
  }

  tags = module.this.tags
}

module "cloudwatch_log_group" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.2"

  enabled = local.logging_enabled
  context = module.this.context
}

resource "aws_glue_job" "this" {
  count = local.enabled ? 1 : 0

  command {
    script_location = local.script_location
    python_version  = 3
  }

  default_arguments = local.job_arguments

  dynamic "execution_property" {
    for_each = var.max_concurrent_runs > 0 ? [1] : []

    content {
      max_concurrent_runs = var.max_concurrent_runs
    }
  }

  glue_version           = var.glue_version
  max_retries            = var.max_retries
  timeout                = var.job_timeout
  name                   = "${module.this.id}-etl-job"
  number_of_workers      = var.number_of_workers
  worker_type            = var.worker_type
  role_arn               = var.role_arn
  security_configuration = var.security_configuration_name
  tags                   = module.this.tags
}