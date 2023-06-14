locals {
  s3_bucket_source_name      = module.s3_bucket_source.bucket_id
  s3_bucket_destination_name = module.s3_bucket_destination.bucket_id
  role_arn                   = module.iam_role.arn
  glue_catalog_database_name = module.glue_catalog_database.name
}

module "s3_bucket_source" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

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

module "s3_bucket_destination" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

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

# https://docs.aws.amazon.com/glue/latest/dg/populate-data-catalog.html
module "glue_catalog_database" {
  source = "../../modules/glue-catalog-database"

  catalog_database_description = "Glue Catalog database with data located in S3 bucket"
  location_uri                 = format("s3://%s", local.s3_bucket_source_name)

  context = module.this.context
}

module "glue_catalog_table" {
  source = "../../modules/glue-catalog-table"

  catalog_table_description = "Test Glue Catalog table"
  database_name             = local.glue_catalog_database_name

  parameters = {
    "lakeformation.aso.status" = true
    "classification"           = "parquet"
  }

  storage_descriptor = {
    # List of reducer grouping columns, clustering columns, and bucketing columns in the table
    bucket_columns = null
    # Configuration block for columns in the table
    columns = [
      {
        name = "county",
        type = "string"
      },
      {
        name = "state",
        type = "string"
      },
      {
        name = "region",
        type = "string"
      }
    ]
    # Whether the data in the table is compressed
    compressed = false
    # Input format: SequenceFileInputFormat (binary), or TextInputFormat, or a custom format
    input_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    # Physical location of the table. By default this takes the form of the warehouse location, followed by the database location in the warehouse, followed by the table name
    location = format("s3://%s/data", local.s3_bucket_source_name)
    #  Must be specified if the table contains any dimension columns
    number_of_buckets = 0
    # Output format: SequenceFileOutputFormat (binary), or IgnoreKeyTextOutputFormat, or a custom format
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    # Configuration block for serialization and deserialization ("SerDe") information
    ser_de_info = {
      # Map of initialization parameters for the SerDe, in key-value form
      parameters = {
        "serialization.format" = "1"
      }
      # Usually the class that implements the SerDe. An example is org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
    # Whether the table data is stored in subdirectories
    stored_as_sub_directories = false
  }

  context = module.this.context
}

module "glue_crawler" {
  source = "../../modules/glue-crawler"

  crawler_description = "Glue crawler that processes data in the source S3 bucket and writes the result into the destination S3 bucket"
  database_name       = local.glue_catalog_database_name
  role                = local.role_arn
  schedule            = "cron(0 1 * * ? *)"

  schema_change_policy = {
    delete_behavior = "LOG"
    update_behavior = null
  }

  s3_target = [
    {
      path = format("s3://%s", local.s3_bucket_destination_name)
    }
  ]

  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      }
      CrawlerOutput = {
        Partitions = {
          AddOrUpdateBehavior = "InheritFromTable"
        }
      }
      Version = 1
    }
  )

  context = module.this.context
}
