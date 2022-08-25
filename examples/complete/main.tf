locals {
  s3_bucket_job_source_arn = module.s3_bucket_job_source.bucket_arn
  role_arn                 = module.iam_role.arn
}

module "s3_bucket_job_source" {
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
    "Service" = ["glue.amazonaws.com"]
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  ]

  policy_document_count = 0
  policy_description    = "Policy for AWS Glue with access to EC2, S3, and Cloudwatch Logs"
  role_description      = "Role for AWS Glue with access to EC2, S3, and Cloudwatch Logs"

  context = module.this.context
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_workflow
module "glue_workflow" {
  source = "../../modules/glue-workflow"

  workflow_description = "Test Glue Workflow"
  max_concurrent_runs  = 2

  context = module.this.context
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job
module "glue_job" {
  source = "../../modules/glue-job"

  job_description   = "Glue Job that runs a Python script"
  role_arn          = local.role_arn
  glue_version      = var.glue_version
  worker_type       = "Standard"
  number_of_workers = 2
  max_retries       = 2

  # The job timeout in minutes
  timeout = 20

  command = {
    # The name of the job command. Defaults to `glueetl`.
    # Use `pythonshell` for Python Shell Job Type, or `gluestreaming` for Streaming Job Type.
    name            = "glueetl"
    script_location = format("s3://%s/example.py", local.s3_bucket_job_source_arn)
    python_version  = 3
  }

  context = module.this.context
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_trigger
module "glue_trigger" {
  source = "../../modules/glue-trigger"

  workflow_name       = module.glue_workflow.name
  trigger_enabled     = true
  start_on_creation   = true
  trigger_description = "Glue Trigger that triggers a Glue Job on a schedule"
  schedule            = "cron(15 12 * * ? *)"
  type                = "SCHEDULED"

  actions = [
    {
      job_name = module.glue_job.name
      # The job run timeout in minutes. It overrides the timeout value of the job
      timeout = 10
    }
  ]

  context = module.this.context
}
