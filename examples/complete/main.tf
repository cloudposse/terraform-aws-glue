locals {
  enabled          = module.this.enabled
  s3_bucket_source = module.s3_bucket_source.bucket_id
  role_arn         = module.iam_role.arn

  # The dataset used in this example consists of Medicare-Provider payment data downloaded from two Data.CMS.gov sites:
  # Inpatient Prospective Payment System Provider Summary for the Top 100 Diagnosis-Related Groups - FY2011, and Inpatient Charge Data FY 2011.
  # AWS modified the data to introduce a couple of erroneous records at the tail end of the file
  data_source = "s3://awsglue-datasets/examples/medicare/Medicare_Hospital_Provider.csv"
}

module "glue_catalog_database" {
  source = "../../modules/glue-catalog-database"

  catalog_database_name        = "payments"
  catalog_database_description = "Glue Catalog database for the data located in ${local.data_source}"
  location_uri                 = local.data_source

  context = module.this.context
}

module "glue_catalog_table" {
  source = "../../modules/glue-catalog-table"

  catalog_table_name        = "medicare"
  catalog_table_description = "Test Glue Catalog table"
  database_name             = module.glue_catalog_database.name

  storage_descriptor = {
    # Physical location of the table
    location = local.data_source
  }

  partition_keys = var.glue_catalog_table_partition_keys

  context = module.this.context
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_permissions
# Grant Lake Formation permissions to the IAM role that the Glue crawler uses to access Glue resources.
# This prevents the error:
# Error: error creating Glue crawler: InvalidInputException: Insufficient Lake Formation permission(s) on medicare (Service: AmazonDataCatalog; Status Code: 400; Error Code: AccessDeniedException
# https://aws.amazon.com/premiumsupport/knowledge-center/glue-insufficient-lakeformation-permissions/
resource "aws_lakeformation_permissions" "default" {
  count = local.enabled ? 1 : 0

  principal   = local.role_arn
  permissions = ["ALL"]

  table {
    database_name = module.glue_catalog_database.name
    name          = module.glue_catalog_table.name
  }
}

# Crawls the data in the S3 bucket and puts the results into a database in the Glue Data Catalog.
# The crawler will read the first 2 MB of data from that file, and recognize the schema.
# After that, the crawler will sync the table `medicare` in the Glue database.
module "glue_crawler" {
  source = "../../modules/glue-crawler"

  crawler_description = "Glue crawler that processes data in ${local.data_source} and writes the metadata into a Glue Catalog database"
  database_name       = module.glue_catalog_database.name
  role                = local.role_arn
  schedule            = "cron(0 1 * * ? *)"

  schema_change_policy = {
    delete_behavior = "LOG"
    update_behavior = null
  }

  catalog_target = [
    {
      database_name = module.glue_catalog_database.name
      tables        = [module.glue_catalog_table.name]
    }
  ]

  context = module.this.context

  depends_on = [
    aws_lakeformation_permissions.default
  ]
}

# Source S3 bucket to store Glue Job scripts
module "s3_bucket_source" {
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

  attributes = ["source"]
  context    = module.this.context
}

resource "aws_s3_object" "job_script" {
  count = local.enabled ? 1 : 0

  bucket        = local.s3_bucket_source
  key           = "data_cleaning.py"
  source        = "${path.module}/scripts/data_cleaning.py"
  force_destroy = true
  etag          = filemd5("${path.module}/scripts/data_cleaning.py")

  tags = module.this.tags
}

# Destination S3 bucket to store Glue Job results
module "s3_bucket_destination" {
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

  attributes = ["destination"]
  context    = module.this.context
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

  job_description   = "Glue Job that runs data_cleaning.py Python script"
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
    script_location = format("s3://%s/data_cleaning.py", local.s3_bucket_source)
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
