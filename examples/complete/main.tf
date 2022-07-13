module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "2.0.3"

  acl                          = "private"
  versioning_enabled           = false
  force_destroy                = true
  allow_encrypted_uploads_only = true
  allow_ssl_requests_only      = true
  block_public_acls            = true
  block_public_policy          = true
  ignore_public_acls           = true
  restrict_public_buckets      = true

  context = module.this.context
}

module "iam_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.16.2"

  principals = {
    "Service" : ["glue.amazonaws.com"]
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  ]

  policy_description = "Policy for AWS Glue which allows access to related services including EC2, S3, and Cloudwatch Logs"
  role_description   = "Role for AWS Glue which allows access to related services including EC2, S3, and Cloudwatch Logs"

  context = module.this.context
}

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
}
