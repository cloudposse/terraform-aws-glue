locals {
  role_arn                   = module.iam_role.arn
  glue_catalog_database_name = module.glue_catalog_database.name
}

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

# https://docs.aws.amazon.com/glue/latest/dg/populate-data-catalog.html
module "glue_catalog_database" {
  source = "../../modules/glue-catalog-database"

  catalog_database_description = "Test Glue Catalog database"

  context = module.this.context
}

module "glue_catalog_table" {
  source = "../../modules/glue-catalog-table"

  catalog_table_description = "Test Glue Catalog table"
  database_name             = local.glue_catalog_database_name

  context = module.this.context
}

module "glue_crawler" {
  source = "../../modules/glue-crawler"

  crawler_description = "Glue crawler that takes inventory of the S3 data and adds metadata tables into the Data Catalog"
  database_name       = local.glue_catalog_database_name
  role                = local.role_arn
  schedule            = "cron(0 1 * * ? *)"

  schema_change_policy = {
    delete_behavior = "LOG"
  }

  catalog_target = [
    {
      database_name = local.glue_catalog_database_name
      tables        = [module.glue_catalog_table.name]
    }
  ]

  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      }
      CrawlerOutput = {
        Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      }
      Version = 1
    }
  )

  context = module.this.context
}
