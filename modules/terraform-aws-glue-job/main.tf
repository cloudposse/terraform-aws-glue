locals {
  enabled                = module.this.enabled
  logging_enabled        = var.logging_enabled
  metrics_enabled        = var.metrics_enabled
  extra_py_files_enabled = length(var.extra_py_files) > 0
  extra_files_enabled    = length(var.extra_files) > 0
  metrics_arguments = {
    "--enable-metrics" = ""
  }
  logging_arguments = {
    "--continuous-log-logGroup"          = module.cloudwatch_log_group.log_group_name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
  }
  spark_arguments = {
    "--enable-spark-ui"       = true,
    "--spark-event-logs-path" = var.spark_event_logs_path
  }
  job_arguments = merge(
    var.default_arguments,
    local.logging_enabled ? local.logging_arguments : {},
    local.metrics_enabled ? local.metrics_arguments : {},
    local.extra_py_files_enabled ? { "--extra-py-files" = join(",", var.extra_py_files) } : {},
    local.extra_files_enabled ? { "--extra-py-files" = join(",", var.extra_files) } : {},
    var.spark_ui_enabled ? local.spark_arguments : {},
    var.glue_datacatalog_enabled ? { "--enable-glue-datacatalog" = "" } : {},
    var.s3_parquet_optimized_committer_enabled ? { "--enable-s3-parquet-optimized-committer" = true } : {},
    var.auto_scaling_enabled ? { "--enable-auto-scaling" = true } : {},
    var.rename_algorithm_v2_enabled ? { "--enable-rename-algorithm-v2" = true } : {},
    var.job_bookmark_option != "" ? { "--job-bookmark-option" = var.job_bookmark_option } : {},
    var.tempdir != "" ? { "--TempDir" = var.tempdir } : {},
  )
}

module "cloudwatch_log_group" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.2"

  stream_names = [module.this.name]

  iam_role_enabled = false

  retention_in_days = var.cloudwatch_logs_retention_in_days

  enabled = local.logging_enabled

  context = module.this.context

  tags = module.this.tags
}

resource "aws_glue_job" "this" {
  count = local.enabled ? 1 : 0

  command {
    script_location = var.script_s3_key
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
  timeout                = var.timeout
  name                   = module.this.id
  number_of_workers      = var.number_of_workers
  worker_type            = var.worker_type
  role_arn               = var.role_arn
  security_configuration = var.security_configuration
  tags                   = module.this.tags
}
