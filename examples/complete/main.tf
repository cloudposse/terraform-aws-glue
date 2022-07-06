module "workflow_example" {
  source = "../../modules/glue-workflow"

  crawler_name           = var.crawler_name
  cron_schedule          = var.cron_schedule
  datalake_bucket        = var.datalake_bucket
  datalake_format        = var.datalake_format
  datalake_prefix        = var.datalake_prefix
  glue_version           = var.glue_version
  job_timeout            = var.job_timeout
  max_concurrent_runs    = var.max_concurrent_runs
  max_retries            = var.max_retries
  number_of_workers      = var.number_of_workers
  optimal_partition_size = var.optimal_partition_size
  role_arn               = var.role_arn
  script_s3_bucket       = var.script_s3_bucket
  script_s3_prefix       = var.script_s3_prefix
  script_template        = var.script_template
  worker_type            = var.worker_type
  region                 = var.region
}
